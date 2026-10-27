require "test_helper"

class RenderStartScriptTest < ActiveSupport::TestCase
  test "start script prepares and seeds the database before starting Rails" do
    script = Rails.root.join("bin/render-start")

    assert_path_exists script
    assert_predicate script, :executable?

    source = script.read
    prepare_position = source.index("bin/rails db:prepare")
    seed_position = source.index("bin/rails db:seed")
    server_position = source.index("exec ./bin/thrust ./bin/rails server")

    assert prepare_position
    assert seed_position
    assert server_position
    assert_operator prepare_position, :<, seed_position
    assert_operator seed_position, :<, server_position
  end
end
