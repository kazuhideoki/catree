import gleam/io
import gleam/list
import simplifile

pub type GetTargetFilePathsDeps {
  GetTargetFilePathsDeps(
    read_directory: fn(String) -> Result(List(String), GetTargetFilePathsError),
    is_file: fn(String) -> Result(Bool, GetTargetFilePathsError),
    // is_gitignore: fn(String) -> Result(Bool, simplifile.FileError),
  )
}

pub type GetTargetFilePathsError {
  ReadDirectoryError(String)
  IsFileError(String)
  // IsGitignoreError(simplifile.FileError),
}

pub fn read_directory(
  directory_path: String,
) -> Result(List(String), GetTargetFilePathsError) {
  case simplifile.read_directory(directory_path) {
    Ok(paths) -> Ok(paths)
    Error(_) ->
      Error(ReadDirectoryError("Failed to read directory: " <> directory_path))
  }
}

pub fn is_file(path: String) -> Result(Bool, GetTargetFilePathsError) {
  case simplifile.is_file(path) {
    Ok(is_file) -> Ok(is_file)
    Error(_) ->
      Error(IsFileError(
        "Failed to check if the file: " <> path <> " is a file or not",
      ))
  }
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
