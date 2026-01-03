import gleam/io
import gleam/list
import simplifile

/// Get all target file paths from given paths.
pub fn get_target_file_paths(absolute_paths: List(String)) -> List(String) {
  list.fold(absolute_paths, [], fn(acc, path) {
    let assert Ok(is_file) = simplifile.is_file(path)

    case is_file {
      True -> list.append(acc, [path])
      False ->
        list.append(acc, get_target_file_paths(list_paths_from_directory(path)))
    }
  })
}

fn list_paths_from_directory(directory_path: String) -> List(String) {
  let result = simplifile.read_directory(directory_path)

  case result {
    Ok(paths) -> list.map(paths, fn(path) { directory_path <> "/" <> path })
    Error(error) -> {
      io.println("directory: " <> directory_path)
      echo error
      []
    }
  }
}
