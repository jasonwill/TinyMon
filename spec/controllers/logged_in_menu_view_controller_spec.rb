describe LoggedInMenuViewController do
  extend WebStub::SpecHelpers
  extend MotionResource::SpecHelpers

  before do
    Account.current = Account.instantiate(:id => 5, :role => 'user', :name => 'Test account')
    User.current = User.instantiate(:id => 1, :role => 'user', :full_name => 'John Doe')
  end
  
  tests LoggedInMenuViewController
  
  it "should show account name" do
    view('Test account').should.not.be.nil
  end
  
  it "should show user name" do
    view('John Doe').should.not.be.nil
  end
  
  it "should show other menu items" do
    view('Activity').should.not.be.nil
    view('Sites').should.not.be.nil
  end
  
  it "should have multiple sections" do
    controller.tableView.numberOfSections.should == LoggedInMenuViewController::ITEMS.size
  end
  
  it "should show other section headers" do
    view('Monitoring').should.not.be.nil
    view('Account').should.not.be.nil
  end
  
  it "should have a zero-height first section header" do
    controller.tableView(controller.tableView, heightForHeaderInSection:0).should == 0
  end
  
  it "should show login form on log out" do
    tap view("Log out")
    view('Login').should.not.be.nil
  end
    
  it "should forget default URL options on logout" do
    MotionResource::Base.default_url_options = { :foo => 'bar' }
    tap view("Log out")
    MotionResource::Base.default_url_options.should.be.nil
  end

  describe "disclosing" do
    before do
      controller.viewDeckController.mock!(:centerController=)
      controller.viewDeckController.mock!(:toggleLeftView)
    end
    
    it "should disclose current user" do
      stub_request(:get, "http://mon.tinymon.org/en/users/1.json").to_return(json: { :id => 1, :role => 'user', :full_name => 'John Doe', :email => 'john@doe.com', :accounts => [] })
      tap view("John Doe")
      1.should == 1
    end
    
    it "should disclose activity" do
      tap view("Activity")
      1.should == 1
    end
    
    it "should disclose sites" do
      tap view("Sites")
      1.should == 1
    end
    
    it "should disclose health checks" do
      tap view("Health Checks")
      1.should == 1
    end
    
    it "should disclose accounts" do
      tap view("Switch Account")
      1.should == 1
    end
    
    it "should disclose users" do
      tap view("Users")
      1.should == 1
    end
  end
end
