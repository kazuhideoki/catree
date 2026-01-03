import filepath
import gleam/io
import gleam/list
import gleam/regexp

/// Loads the arguments and returns them as absolute paths.
pub fn convert_to_absolute_paths(
  values: List(String),
  cwd: String,
) -> List(String) {
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
                "Invalid path, cannot start with relative path like './', '"
                <> path
                <> "' is ignored",
              )
              Error("")
            }
            False -> Ok(filepath.join(cwd, path))
          }
        }
      }
    })

  absolute_paths
}

fn check_invalid_relative_path(path: String) -> Bool {
  let assert Ok(re) = regexp.from_string("^(\\./|\\.\\./)+")

  regexp.check(with: re, content: path)
}
