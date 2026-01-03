import filepath
import gleam/io
import gleam/list
import gleam/regexp
import simplifile

/// Loads the arguments and returns them as absolute paths.
pub fn convert_to_absolute_paths(
  values: List(String),
  cwd: String,
) -> Result(List(String), _) {
  let absolute_paths =
    list.filter_map(values, fn(path) {
      let is_absolute = filepath.is_absolute(path)
      case is_absolute {
        True -> Ok(path)
        // False -> filepath.join(cwd, path)
        False -> {
          let is_invalid_relative_path = check_invalid_relative_path(path)
          case is_invalid_relative_path {
            True -> {
              io.println_error(
                "Invalid path, cannot start with relative path like './', "
                <> path
                <> " is ignored",
              )
              Error("")
            }
            False -> Ok(filepath.join(cwd, path))
          }
        }
      }
    })

  Ok(absolute_paths)
}

/// Panic if the current directory cannot be retrieved.
pub fn get_current_directory() -> String {
  let cwd = simplifile.current_directory()
  case cwd {
    Ok(path) -> path
    _ -> panic as "Failed to get current directory"
  }
}

fn check_invalid_relative_path(path: String) -> Bool {
  let assert Ok(re) = regexp.from_string("^(\\./|\\.\\./)+")

  regexp.check(with: re, content: path)
}
