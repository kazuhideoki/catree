import catree/target_finder

pub fn get_target_file_paths_test() {
  assert target_finder.get_target_file_paths(
      ["/Users/hoge"],
      target_finder.GetTargetFilePathsDeps(
        fn(path) {
          case path {
            "/Users/hoge" -> Ok(["foo.txt"])
            _ -> Ok([])
          }
        },
        fn(path) {
          case path {
            "/Users/hoge/foo.txt" -> Ok(True)
            "/Users/hoge" -> Ok(False)
            _ -> Ok(False)
          }
        },
      ),
    )
    == ["/Users/hoge/foo.txt"]
}

pub fn get_target_file_paths_multiple_paths_test() {
  assert target_finder.get_target_file_paths(
      ["/Users/hoge", "/Users/hoge/baz.txt"],
      target_finder.GetTargetFilePathsDeps(
        fn(path) {
          case path {
            "/Users/hoge" -> Ok(["foo.txt", "bar.txt"])
            _ -> Ok([])
          }
        },
        fn(path) {
          case path {
            "/Users/hoge/foo.txt" -> Ok(True)
            "/Users/hoge/bar.txt" -> Ok(True)
            "/Users/hoge/baz.txt" -> Ok(True)
            "/Users/hoge" -> Ok(False)
            _ -> Ok(False)
          }
        },
      ),
    )
    == ["/Users/hoge/foo.txt", "/Users/hoge/bar.txt", "/Users/hoge/baz.txt"]
}
