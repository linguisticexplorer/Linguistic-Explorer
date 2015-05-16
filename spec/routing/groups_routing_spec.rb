require "spec_helper"

describe GroupsController do
  describe "group level routing" do
    it "recognizes and generates #index" do
      expect({:get => "/groups" }).to route_to(:controller => "groups", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({:get => "/groups/new" }).to route_to(:controller => "groups", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({:get => "/groups/1" }).to route_to(:controller => "groups", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({:get => "/groups/1/edit" }).to route_to(:controller => "groups", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({:post => "/groups" }).to route_to(:controller => "groups", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({:put => "/groups/1" }).to route_to(:controller => "groups", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({:delete => "/groups/1" }).to route_to(:controller => "groups", :action => "destroy", :id => "1")
    end
  end

  describe 'nested routes for' do
    nested_resources = ["lings", "properties", "lings_properties", "examples", "categories", "memberships", "examples_lings_properties"]
    nested_resources.each do |resource|
      skip_edit_and_update = (["examples_lings_properties", "lings_properties"].include? resource)
      skip_new_and_create = (["lings_properties"].include? resource)
      skip_index = (["examples_lings_properties", "lings_properties"].include? resource)

      describe resource do
        unless skip_index
          it "recognizes and generates #index" do
            expect({:get => "groups/1/#{resource}" }).to route_to(:controller => resource, :action => "index", :group_id => "1")
          end
        end

        it "recognizes and generates #show" do
          expect({:get => "groups/1/#{resource}/1" }).to route_to(:controller => resource, :action => "show", :id => "1", :group_id => "1")
        end

        it "recognizes and generates #destroy" do
          expect({:delete => "groups/1/#{resource}/1" }).to route_to(:controller => resource, :action => "destroy", :id => "1", :group_id => "1")
        end

        unless skip_new_and_create
          it "recognizes and generates #new" do
            expect({:get => "groups/1/#{resource}/new" }).to route_to(:controller => resource, :action => "new", :group_id => "1")
          end

          it "recognizes and generates #create" do
            expect({:post => "groups/1/#{resource}" }).to route_to(:controller => resource, :action => "create", :group_id => "1")
          end
        end

        unless skip_edit_and_update
          it "recognizes and generates #edit" do
            expect({:get => "groups/1/#{resource}/1/edit" }).to route_to(:controller => resource, :action => "edit", :id => "1", :group_id => "1")
          end

          it "recognizes and generates #update" do
            expect({:put => "groups/1/#{resource}/1" }).to route_to(:controller => resource, :action => "update", :id => "1", :group_id => "1")
          end
        end
      end
    end
  end
end
