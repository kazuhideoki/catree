import catree/paths
import gleeunit/should

pub fn convert_to_absolute_paths_relative_path_test() {
  should.equal(
    paths.convert_to_absolute_paths(["src/hoge"], "/Users/foo"),
    Ok(["/Users/foo/src/hoge"]),
  )
}

pub fn convert_to_absolute_paths_already_absolute_path_test() {
  should.equal(
    paths.convert_to_absolute_paths(["/Users/foo/src/hoge"], "/Users/foo"),
    Ok(["/Users/foo/src/hoge"]),
  )
}

pub fn convert_to_absolute_paths_current_dir_prefix_test() {
  should.equal(
    paths.convert_to_absolute_paths(["./src/hoge"], "/Users/foo"),
    Ok([]),
  )
}

pub fn convert_to_absolute_paths_parent_dir_prefix_test() {
  should.equal(
    paths.convert_to_absolute_paths(["../src/hoge"], "/Users/foo"),
    Ok([]),
  )
}
