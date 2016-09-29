## launch the test environment
require '../test1.rb'
require 'minitest/autorun'

# require MSSP

describe MSSP::Room do

  before do
    while @room == nil
      sleep 1
      if $app != nil
          if $app.ready != nil and $app.ready == true
              @room = $app.room
          end
      end
    end
  end


  describe "when asked to create a room" do
    it "must create a valid room object" do
      @room.getGraphics.wont_be_nil
    end
  end

  describe "when asked to create a boite" do
    it "must not create an unnamed boite" do
      @room.boite ""
      @room.boites.size.must_equal 0
    end

    it "must create a special boite for numbers and delete it" do
      # Creation of a textfield... done by the mouse usually
      $app.noLoop
      sleep 1
      @room.text_field = @room.skatolo.addTextfield("boite")
                           .setPosition(100, 100)
                           .setSize(150, 20)
      # Wait for it to be created. ..
      sleep 1
      $app.loop
      @number_boite = @room.boite "42"
      @number_boite.name.must_equal "number"

      $app.noLoop
      sleep 1
      @number_boite.delete
      sleep 1
      $app.loop
      sleep 1
      @room.boites.size.must_equal 0

    end

    it "must clean the textField after creating a boite" do
      @room.text_field.must_be_nil
    end

  end
end
