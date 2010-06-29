require "spec_helper"

describe Mongoid::Associations do

  before do
    Person.collection.remove
  end

  context "embeds_one" do

    context "with attributes hash" do
      describe "creating associated document" do
        let(:person) { Person.create!( :ssn => "1234", :pet_attributes => { :name => 'odie' } ) }
        specify { person.reload.pet.name.should == 'odie' }
      end

      describe "updating associated document" do
        let(:person) { Person.create!( :ssn => "1234", :pet_attributes => { :name => 'garfield' } ) }
        before { person.update_attributes(:pet_attributes => { :name => 'odie' } ) }
        specify { person.reload.pet.name.should == 'odie' }
      end
    end

    context "with a normal hash" do
      describe "creating associated document" do
        let(:person) { Person.create!( :ssn => "1234", :pet => { :name => 'odie' } ) }
        specify { person.reload.pet.name.should == 'odie' }
      end

      describe "updating associated document" do
        let(:person) { Person.create!( :ssn => "1234", :pet => { :name => 'garfield' }) }
        before { person.update_attributes!(:pet => { :name => 'odie' } ) }
        specify { person.reload.pet.name.should == 'odie' }
      end
    end

  end

  context "embeds_many" do

    context "with attributes hash" do
      describe "creating associated document" do
        let(:person) { Person.create!( :ssn => "1234", :favorites_attributes => { '0' => { :title => 'something' } } ) }
        specify { person.reload.favorites.first.title.should == 'something' }
      end

      describe "updating associated document" do
        let(:person) { Person.create!( :ssn => "1234", :favorites => [{ :title => 'nothing' }]) }
        before { person.update_attributes(:favorites_attributes => {'0' => { :title => 'something' } } ) }
        specify { person.reload.favorites.first.title.should == 'something' }
      end
    end

    context "with a normal hash" do
      describe "creating associated document" do
        let(:person) { Person.create!( :ssn => "1234", :favorites => [{ :title => 'something' }] ) }
        specify { person.reload.favorites.first.title.should == 'something' }
      end

      describe "updating associated document" do
        let(:person) { x = Person.create!( :ssn => "1234", :favorites => [{ :title => 'nothing' }] ) ; p x ; x }
        before { person.update_attributes(:favorites => [{ :title => 'something' }, {:title => 'hello'}]) }
        specify { person.reload.favorites.first.title.should == 'something' }
      end
    end
  end

end
