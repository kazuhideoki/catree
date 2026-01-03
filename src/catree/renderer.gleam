import filepath
import gleam/io
import gleam/result
import simplifile

pub type PrintFileDeps {
  PrintFileDeps(
    read_file: fn(String) -> Result(String, PrintFileError),
    read_extension: fn(String) -> Result(String, PrintFileError),
  )
}

pub type PrintFileError {
  ReadError(String)
  ReadExtensionError(String)
}

pub fn read_file(absolute_path: String) -> Result(String, PrintFileError) {
  case simplifile.read(absolute_path) {
    Ok(content) -> Ok(content)
    Error(_) -> Error(ReadError("Cannot read file: " <> absolute_path))
  }
}

pub fn read_extension(absolute_path: String) -> Result(String, PrintFileError) {
  case filepath.extension(absolute_path) {
    Ok(content) -> Ok(content)
    Error(_) ->
      Error(ReadExtensionError("Cannot read extension: " <> absolute_path))
  }
}

pub fn print_file(
  absolute_path: String,
  deps: PrintFileDeps,
) -> Result(Nil, PrintFileError) {
  use content <- result.try(deps.read_file(absolute_path))
  use ext <- result.try(deps.read_extension(absolute_path))
  let lang = get_lang_type(ext)

  io.println(absolute_path)
  io.println("~~~" <> lang)
  io.println(content)
  io.println("~~~")
  io.println("")

  Ok(Nil)
}

fn get_lang_type(ext: String) -> String {
  case ext {
    "sh" -> "sh"
    "ts" -> "typescript"
    "js" -> "javascript"
    "py" -> "python"
    "md" -> "markdown"
    "json" -> "json"
    "jsonc" -> "jsonc"
    "yml" -> "yaml"
    "rb" -> "ruby"
    "rs" -> "rust"
    "c" | "cpp" | "h" | "hpp" -> "cpp"
    unknown -> unknown
  }
}
