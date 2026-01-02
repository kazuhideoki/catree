#!/usr/bin/env bash
# catree.sh ─ ファイルまたはディレクトリを Markdown コードフェンスでまとめて出力
# 使い方:
#   ./catree.sh <file>                    # 単一ファイル
#   ./catree.sh <directory>               # ディレクトリ配下を再帰
#   ./catree.sh <file1> <file2> ...       # 複数ファイル
#   ./catree.sh <dir1> <dir2> ...         # 複数ディレクトリ
#   ./catree.sh <file1> <dir1> ...        # 混合

set -euo pipefail

usage() {
    echo "Usage: $0 <file-or-directory> [<file-or-directory> ...]" >&2
    echo "       Process multiple files and directories and output contents with Markdown code fences" >&2
    exit 1
}

IGNORE_PATTERNS=()
ARGS=()

# 引数パース
while [[ $# -gt 0 ]]; do
    case "$1" in
    --help | -h)
        echo "catree - Output file or directory contents with Markdown code fences"
        echo
        echo "Usage:"
        echo "  $0 <file>                      # Single file"
        echo "  $0 <directory>                 # Directory (recursive)"
        echo "  $0 <file1> <file2> ...        # Multiple files"
        echo "  $0 <dir1> <dir2> ...          # Multiple directories"
        echo "  $0 <file1> <dir1> ...         # Mixed files and directories"
        echo
        echo "Options:"
        echo "  --exclude <pattern>            # Exclude files/directories matching pattern"
        echo "  --exclude=<pattern>            # Same as --exclude <pattern>"
        echo "  -h, --help                     # Show this help message"
        echo
        echo "Examples:"
        echo "  $0 main.py"
        echo "  $0 src/"
        echo "  $0 --exclude=node_modules src/"
        echo "  $0 --exclude '*.log' --exclude build/ ."
        exit 0
        ;;
    --exclude)
        shift
        [[ $# -gt 0 ]] || usage
        IGNORE_PATTERNS+=("$1")
        ;;
    --exclude=*)
        IGNORE_PATTERNS+=("${1#--exclude=}")
        ;;
    -*)
        echo "Unknown option: $1" >&2
        usage
        ;;
    *)
        ARGS+=("$1")
        ;;
    esac
    shift
done

[[ ${#ARGS[@]} -ge 1 ]] || usage

# 無視パターンファイル（gitignore 互換）を読み込む関数 -------------------------
load_catreeignore() {
    # スクリプト自身のディレクトリ
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # 優先度: 1) scripts/catree/catreeignore.sh 2) カレントの .catreeignore
    local candidates=(
        "$script_dir/catreeignore.sh"
        ".catreeignore"
    )

    for ignore_file in "${candidates[@]}"; do
        if [[ -f "$ignore_file" && -r "$ignore_file" ]]; then
            echo "# Loading ignore patterns: $ignore_file" >&2
            while IFS= read -r line || [[ -n "$line" ]]; do
                # 空行とコメント行をスキップ
                [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
                # 前後の空白を削除
                line="${line#"${line%%[![:space:]]*}"}"
                line="${line%"${line##*[![:space:]]}"}"
                [[ -n "$line" ]] && IGNORE_PATTERNS+=("$line")
            done <"$ignore_file"
        fi
    done
}

# 無視パターンを読み込む
load_catreeignore

# 除外判定関数
is_excluded() {
    local path="$1"
    local rel_path="${path#$PWD/}"

    local excluded=false

    for raw in "${IGNORE_PATTERNS[@]+"${IGNORE_PATTERNS[@]}"}"; do
        local neg=false
        local pat="$raw"
        if [[ "$pat" == '!'* ]]; then
            neg=true
            pat="${pat:1}"
        fi

        # ディレクトリパターン（末尾が/）
        if [[ "$pat" == */ ]]; then
            local dir_pat="${pat%/}"
            if [[ "$rel_path" == "$dir_pat" ]] || [[ "$rel_path" == "$dir_pat/"* ]]; then
                if $neg; then excluded=false; else excluded=true; fi
                continue
            fi
            if [[ "$(basename "$path")" == "$dir_pat" ]]; then
                if $neg; then excluded=false; else excluded=true; fi
                continue
            fi
        fi

        # ファイル名/ワイルドカード/相対一致のざっくり評価
        if [[ "$(basename "$path")" == $pat ]] || [[ "$rel_path" == $pat ]] || [[ "$path" == $pat ]] || [[ "$path" == $PWD/$pat ]]; then
            if $neg; then excluded=false; else excluded=true; fi
            continue
        fi
    done

    $excluded && return 0 || return 1
}

# 共通処理：バイナリ判定＋コードフェンス出力 ---------------------------------
print_file() {
    local path="$1" # 絶対パス
    local rel="$2"  # 表示用パス（相対 or ファイル名）

    if is_excluded "$path"; then
        echo "# Excluded: $rel" >&2
        return 0
    fi

    if ! [[ -r "$path" ]]; then
        echo "# Cannot read file: $rel" >&2
        return 1
    fi

    if file --mime "$path" | grep -q 'charset=binary'; then
        echo "# Skipped binary file: $rel" >&2
        return 0
    fi

    # 拡張子 → ハイライト言語
    local ext="${rel##*.}"
    local lang=""
    case "$ext" in
    sh) lang=sh ;;
    ts) lang=typescript ;;
    js) lang=javascript ;;
    py) lang=python ;;
    md) lang=markdown ;;
    json) lang=json ;;
    yml | yaml) lang=yaml ;;
    rb) lang=ruby ;;
    rs) lang=rust ;;
    go) lang=go ;;
    c | cpp | h | hpp) lang=cpp ;;
    java) lang=java ;;
    php) lang=php ;;
    html) lang=html ;;
    css) lang=css ;;
    xml) lang=xml ;;
    toml) lang=toml ;;
    lean) lang=lean ;;
    esac

    echo "$rel"
    echo "~~~$lang"
    cat "$path"
    echo "~~~"
    echo
    return 0
}

# パスを絶対パスに解決する関数 ------------------------------------------------
resolve_path() {
    local path="$1"

    # 絶対パスの場合はそのまま返す
    if [[ "$path" = /* ]]; then
        echo "$path"
        return
    fi

    # 相対パスの場合は現在のディレクトリからの絶対パスを返す
    echo "$PWD/$path"
}

# ディレクトリを処理する関数 -------------------------------------------------
process_directory() {
    local dir="$1"
    local original_pwd="$PWD"
    local dir_name="$(basename "$dir")"

    if is_excluded "$dir"; then
        echo "# Excluded directory: $dir" >&2
        return 0
    fi

    if ! cd "$dir" 2>/dev/null; then
        echo "Error: Cannot access directory '$dir'" >&2
        return 1
    fi

    # ディレクトリ内のファイルが存在するか確認
    if ! find . -type f -print -quit | grep -q .; then
        echo "Note: Directory '$dir' is empty or contains no regular files" >&2
    else
        find . -type f | sort | while read -r file; do
            # 除外判定（順序付き・!対応）
            if is_excluded "$PWD/$file"; then
                echo "# Excluded: $dir_name/${file#./}" >&2
                continue
            fi
            print_file "$PWD/$file" "$dir_name/${file#./}"
        done
    fi

    cd "$original_pwd"
    return 0
}

# 単一パスを処理する関数 ------------------------------------------------------
process_path() {
    local path="$1"

    if [[ ! -e "$path" ]]; then
        echo "Error: '$path' does not exist" >&2
        return 1
    elif [[ ! -r "$path" ]]; then
        echo "Error: '$path' is not readable" >&2
        return 1
    elif [[ -f "$path" ]]; then
        # 単一ファイル
        print_file "$path" "$(basename "$path")"
    elif [[ -d "$path" ]]; then
        # ディレクトリ
        process_directory "$path"
    else
        echo "Error: '$path' is neither a regular file nor directory" >&2
        return 1
    fi
    return 0
}

# --- メインロジック -----------------------------------------------------------
exit_code=0
processed=0

for arg in "${ARGS[@]}"; do
    target=$(resolve_path "$arg")

    if is_excluded "$target"; then
        echo "# Excluded: $arg" >&2
        continue
    fi

    if ! process_path "$target"; then
        exit_code=1
        echo "# Skipping '$arg' due to error"
        echo
    else
        processed=$((processed + 1))
    fi
done

if [ $processed -eq 0 ]; then
    echo "Warning: No files were successfully processed" >&2
fi

exit $exit_code
