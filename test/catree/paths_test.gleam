import catree/paths

pub fn convert_to_absolute_paths_relative_path_test() {
  assert paths.convert_to_absolute_paths(["src/hoge"], "/Users/foo")
    == ["/Users/foo/src/hoge"]
}

pub fn convert_to_absolute_paths_relative_path_file_test() {
  assert paths.convert_to_absolute_paths(["src/hoge.txt"], "/Users/foo")
    == ["/Users/foo/src/hoge.txt"]
}

pub fn convert_to_absolute_paths_multiple_files_test() {
  assert paths.convert_to_absolute_paths(
      ["src/hoge.txt", "src/fuga.txt", "src/piyo.txt"],
      "/Users/foo",
    )
    == [
      "/Users/foo/src/hoge.txt",
      "/Users/foo/src/fuga.txt",
      "/Users/foo/src/piyo.txt",
    ]
}

pub fn convert_to_absolute_paths_already_absolute_path_test() {
  assert paths.convert_to_absolute_paths(["/Users/foo/src/hoge"], "/Users/foo")
    == ["/Users/foo/src/hoge"]
}

pub fn convert_to_absolute_paths_current_dir_prefix_test() {
  assert paths.convert_to_absolute_paths(["./src/hoge"], "/Users/foo") == []
}

pub fn convert_to_absolute_paths_parent_dir_prefix_test() {
  assert paths.convert_to_absolute_paths(["../src/hoge"], "/Users/foo") == []
}
