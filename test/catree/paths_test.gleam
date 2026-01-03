import catree/paths
import gleeunit/should

// TODO 関数分離
pub fn convert_to_absolute_paths_test() {
  should.equal(
    paths.convert_to_absolute_paths(["src/hoge"], "/Users/foo"),
    Ok(["/Users/foo/src/hoge"]),
  )

  should.equal(
    paths.convert_to_absolute_paths(["/Users/foo/src/hoge"], "/Users/foo"),
    Ok(["/Users/foo/src/hoge"]),
  )

  should.equal(
    paths.convert_to_absolute_paths(["./src/hoge"], "/Users/foo"),
    Ok([]),
  )
  should.equal(
    paths.convert_to_absolute_paths(["../src/hoge"], "/Users/foo"),
    Ok([]),
  )
}
