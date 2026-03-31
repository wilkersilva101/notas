require "application_system_test_case"

class NotaTest < ApplicationSystemTestCase
  setup do
    @notum = nota(:one)
  end

  test "visiting the index" do
    visit nota_url
    assert_selector "h1", text: "Nota"
  end

  test "should create notum" do
    visit nota_url
    click_on "New notum"

    fill_in "Descricao", with: @notum.descricao
    fill_in "Titulo", with: @notum.titulo
    fill_in "User", with: @notum.user_id
    click_on "Create Notum"

    assert_text "Notum was successfully created"
    click_on "Back"
  end

  test "should update Notum" do
    visit notum_url(@notum)
    click_on "Edit this notum", match: :first

    fill_in "Descricao", with: @notum.descricao
    fill_in "Titulo", with: @notum.titulo
    fill_in "User", with: @notum.user_id
    click_on "Update Notum"

    assert_text "Notum was successfully updated"
    click_on "Back"
  end

  test "should destroy Notum" do
    visit notum_url(@notum)
    click_on "Destroy this notum", match: :first

    assert_text "Notum was successfully destroyed"
  end
end
