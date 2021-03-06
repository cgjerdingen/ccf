require 'spec_helper'

describe Event do
  it "should require a start date" do
    should validate_presence_of(:start_date)
  end
  
  it "should require an end date" do
    should validate_presence_of(:end_date)
  end
  
  it "should require a title" do
    should validate_presence_of(:title)
  end
  
  it "should require a description" do
    should validate_presence_of(:description)
  end

  it "should require a registration end date" do
    should validate_presence_of(:registration_end_dt)
  end

  it "should require a registration max" do
    should validate_presence_of(:registration_maximum)
  end
  
  it "should accept a voting end date" do
    should allow_value(Time.now).for(:voting_end_date)
  end
  
  it "should not accept a non-date for voting end date" do
    should allow_value("Some random trash").for(:voting_end_date)
  end
  
  it "should have many projects" do
    should have_many(:projects)
  end
  
  it "should have moderators" do
    should have_many(:moderators)
  end
  
  it "should have many registrations" do
    should have_many(:registrations)
  end
  
  describe "when dealing with voting for projects" do
    it "should be able to enable voting for projects" do
      @event = create(:event, voting_end_date: Date.tomorrow, voting_enabled: true, start_date: Date.tomorrow)
      @event.voting_enabled?.should be_true
    end
  
    it "should be able to disable voting for projects" do
      @event = create(:event, voting_end_date: Date.tomorrow, voting_enabled: 0)
      @event.voting_enabled?.should be_false
    end
  
    it "should not allow voting after voting end date" do
      @event = create(:event, voting_end_date: Date.today, voting_enabled: true)
      @event.voting_enabled?.should be_false
    end
    
    it "should not accept votes if event start date has passed" do
      @event = create(:event, start_date: Date.today, voting_enabled: true, voting_end_date: nil)
      @event.voting_enabled?.should be_false      
    end 
  end
  
  describe "when dealing with volunteering for projects" do
    it "should be able to enable volunteers for projects" do
      @event = create(:event, volunteer_end_date: Date.tomorrow, volunteering_enabled: true, end_date: Date.tomorrow)
      @event.volunteering_enabled?.should be_true
    end
    
    it "should be able to disable volunteers for projects" do
      @event = create(:event, volunteer_end_date: Date.tomorrow, volunteering_enabled: false, end_date: Date.tomorrow)
      @event.volunteering_enabled?.should be_false
    end
    
    it "should not allow volunteering after volunteer end date" do
      @event = create(:event, volunteer_end_date: Date.today, volunteering_enabled: true, end_date: Date.tomorrow)
      @event.volunteering_enabled?.should be_false
    end
    
    it "should not accept votes if event end date has passed" do
      @event = create(:event, volunteer_end_date: nil, volunteering_enabled: true, end_date: Date.today.advance(:days => -1))
      @event.volunteering_enabled?.should be_false
    end

    describe "When dealing with a created event and project" do
      before(:each) do
        @event = create(:event)
        @user = create(:user)
        @project = create(:project, :event => @event)
      end

      it "should calculate the number of votes on associated projects" do
        @event.vote_count.should be(0)
        @project_rating = create(:project_rating, project: @project, user: @user)
        @event.vote_count.should be(1)
      end

      it "should calculate the number of volunteers on associated projects" do
        @event.volunteer_count.should be(0)
        @project_volunteer = create(:project_volunteer, project: @project, user: @user)
        @event.volunteer_count.should be(1)
      end    

      it "should properly determine if a user is registered" do
        @event_registration = create(:event_registration, user: @user, event: @event)
        @event.registered?(@user).should be_true  
      end

      it "should properly determine the number of registrations remaining" do
        @event_registration = create(:event_registration, user: @user, event: @event)
        @event.registrations_remaining.should be(125)
      end      
    end
  end
end
