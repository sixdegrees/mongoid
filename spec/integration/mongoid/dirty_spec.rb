require "spec_helper"

describe Mongoid::Dirty do

  before do
    Person.collection.remove
  end

  after do
    Person.collection.remove
  end

  context "when fields are getting changed" do

    before do
      @person = Person.create(:title => "MC", :ssn => "234-11-2533", :some_dynamic_field => 'blah')
      @person.title = "DJ"
      @person.write_attribute(:ssn, "222-22-2222")

      @person.some_dynamic_field = 'bloop'
    end

    it "marks the document as changed" do
      @person.changed?.should == true
    end

    it "marks field changes" do
      @person.changes.should == {
        "title" => [ "MC", "DJ" ],
        "ssn" => [ "234-11-2533", "222-22-2222" ],
        "some_dynamic_field" => [ "blah", "bloop" ]
      }
    end

    it "marks changed fields" do
      @person.changed.should == [ "title", "ssn", "some_dynamic_field" ]
    end

    it "marks the field as changed" do
      @person.title_changed?.should == true
    end

    it "stores previous field values" do
      @person.title_was.should == "MC"
    end

    it "marks field changes" do
      @person.title_change.should == [ "MC", "DJ" ]
    end

    it "allows reset of field changes" do
      @person.reset_title!
      @person.title.should == "MC"
      @person.changed.should == [ "ssn", "some_dynamic_field" ]
    end

    context "after a save" do

      before do
        @person.save!
      end

      it "clears changes" do
        @person.changed?.should == false
      end

      it "stores previous changes" do
        @person.previous_changes["title"].should == [ "MC", "DJ" ]
        @person.previous_changes["ssn"].should == [ "234-11-2533", "222-22-2222" ]
      end
    end
  end

  context "when associations are getting changed" do

    before do
      @person = Person.create(:addresses => [Address.new])
      @person.addresses = [Address.new]
    end

    it "should not set the association to nil when hitting the database" do
      @person.setters.should_not == {"addresses" => nil}
    end
  end

  context "with an embeds_one association" do
    before do
      @person = Person.create(:title => "MC", :ssn => "234-11-2533")
    end

    it 'should mark change in embeds_one if change' do
      @person.pet = Pet.new(:name => 'mustache')
      @person.changes.should == {'pet' => [nil, @person.pet]}
    end

    it 'should mark change in embeds_one add with build method' do
      @person.build_pet(:name => 'mustache')
      @person.changes.should == {'pet' => [nil, @person.pet]}
    end

    it 'should mark change in embeds_one add with create method' do
      @person.create_pet(:name => 'mustache')
      @person.changes.should == {'pet' => [nil, @person.pet]}
    end

    it 'should mark no change in embeds_one if change and delete after' do
      @person.pet = Pet.new(:name => 'mustache')
      @person.pet = nil
      @person.changes.should == {}
    end

    it 'should reset changes from dirty after save document' do
      @person.build_pet(:name => 'mustache')
      @person.save
      @person.changes.should == {}
    end
  end

  context "with an embeds_many association" do
    before do
      @person = Person.create(:title => "MC", :ssn => "234-11-2533")
    end

    it 'should mark change if add only embeds_many by = methods' do
      @person.favorites = [Favorite.new(:title => 'mongodb')]
      @person.changes.should == {'favorites' => [[], [@person.favorites.first]]}
    end

    it 'should mark change if add only embeds_many by = methods and add by << methods' do
      @person.favorites = [Favorite.new(:title => 'mongodb')]
      @person.favorites << Favorite.new(:title => 'mongoid')
      @person.changes.should == {'favorites' => [[], [@person.favorites.first, @person.favorites.second]]}
    end

    it 'should mark change in embeds_many add with build method' do
      @person.favorites.build(:title => 'mongodb')
      @person.changes.should == {'favorites' => [[], [@person.favorites.first]]}
    end

    it 'should mark change in embeds_many add with build method several times' do
      @person.favorites.build(:title => 'mongodb')
      @person.favorites.build(:title => 'mongoid')
      @person.changes.should == {'favorites' => [[], [@person.favorites.first, @person.favorites.second]]}
    end

    it 'should mark change in embeds_many add with create method' do
      @person.favorites.create(:title => 'mongodb')
      @person.changes.should == {'favorites' => [[], [@person.favorites.first]]}
    end

    it 'should mark change in embeds_many add with create method several times' do
      @person.favorites.create(:title => 'mongodb')
      @person.favorites.create(:title => 'mongoid')
      @person.changes.should == {'favorites' => [[], [@person.favorites.first, @person.favorites.second]]}
    end

    it 'should mark no change in embeds_many if change and delete after' do
      @person.favorites = [Favorite.new(:title => 'mongodb')]
      @person.favorites = nil
      @person.changes.should == {}
    end

    it 'should reset changes from dirty after save document' do
      @person.favorites = [Favorite.new(:title => 'mongodb')]
      @person.save
      @person.changes.should == {}
    end
  end
end
