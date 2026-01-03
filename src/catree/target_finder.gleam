import gleam/io
import gleam/list
import simplifile

pub type GetTargetFilePathsDeps {
  GetTargetFilePathsDeps(
    read_directory: fn(String) -> Result(List(String), simplifile.FileError),
    is_file: fn(String) -> Result(Bool, simplifile.FileError),
  )
}

/// Get all target file paths from given paths.
pub fn get_target_file_paths(
  absolute_paths: List(String),
  deps: GetTargetFilePathsDeps,
) -> List(String) {
  list.fold(absolute_paths, [], fn(acc, path) {
    let assert Ok(is_file) = deps.is_file(path)

    case is_file {
      True -> list.append(acc, [path])
      False ->
        list.append(
          acc,
          get_target_file_paths(list_paths_from_directory(path, deps), deps),
        )
    }
  })
}

fn list_paths_from_directory(
  directory_path: String,
  deps: GetTargetFilePathsDeps,
) -> List(String) {
  let result = deps.read_directory(directory_path)

  case result {
    Ok(paths) -> list.map(paths, fn(path) { directory_path <> "/" <> path })
    Error(error) -> {
      io.println("directory: " <> directory_path)
      echo error
      []
    }
  }
}
