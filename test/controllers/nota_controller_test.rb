require "test_helper"

class NotaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @notum = nota(:one)
  end

  test "should get index" do
    get nota_url
    assert_response :success
  end

  test "should get new" do
    get new_notum_url
    assert_response :success
  end

  test "should create notum" do
    assert_difference("Notum.count") do
      post nota_url, params: { notum: { descricao: @notum.descricao, titulo: @notum.titulo, user_id: @notum.user_id } }
    end

    assert_redirected_to notum_url(Notum.last)
  end

  test "should show notum" do
    get notum_url(@notum)
    assert_response :success
  end

  test "should get edit" do
    get edit_notum_url(@notum)
    assert_response :success
  end

  test "should update notum" do
    patch notum_url(@notum), params: { notum: { descricao: @notum.descricao, titulo: @notum.titulo, user_id: @notum.user_id } }
    assert_redirected_to notum_url(@notum)
  end

  test "should destroy notum" do
    assert_difference("Notum.count", -1) do
      delete notum_url(@notum)
    end

    assert_redirected_to nota_url
  end
end
