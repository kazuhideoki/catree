import catree/processor

pub fn get_target_file_paths_test() {
  assert processor.get_target_file_paths(
      ["/Users/hoge"],
      processor.Deps(
        fn(path) {
          case path {
            "/Users/hoge" -> Ok(["fuga.txt"])
            _ -> Ok([])
          }
        },
        fn(path) {
          case path {
            "/Users/hoge/fuga.txt" -> Ok(True)
            "/Users/hoge" -> Ok(False)
            _ -> Ok(False)
          }
        },
      ),
    )
    == ["/Users/hoge/fuga.txt"]
}
