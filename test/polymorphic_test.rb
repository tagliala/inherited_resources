# frozen_string_literal: true
require 'test_helper'

class Factory; end
class Company; end
class User; end
class Photo; end

class Employee
  def self.human_name; 'Employee'; end
end

class EmployeesController < InheritedResources::Base
  belongs_to :factory, :company, polymorphic: true
end

class PhotosController < InheritedResources::Base
  belongs_to :user, :task, polymorphic: true

  def index
    parent
    # Overwrite index
  end
end

class PolymorphicFactoriesTest < ActionController::TestCase
  tests EmployeesController

  def setup
    draw_routes do
      resources :employees
    end

    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)

    @controller.stubs(:resource_url).returns('/')
    @controller.stubs(:collection_url).returns('/')
  end

  def teardown
    clear_routes
  end

  def test_expose_all_employees_as_instance_variable_on_index
    Employee.expects(:scoped).returns([mock_employee])
    get :index, params: { factory_id: '37' }

    assert_equal mock_factory, assigns(:factory)
    assert_equal [mock_employee], assigns(:employees)
  end

  def test_expose_the_requested_employee_on_show
    Employee.expects(:find).with('42').returns(mock_employee)
    get :show, params: { id: '42', factory_id: '37' }

    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_expose_a_new_employee_on_new
    Employee.expects(:build).returns(mock_employee)
    get :new, params: { factory_id: '37' }

    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_expose_the_requested_employee_on_edit
    Employee.expects(:find).with('42').returns(mock_employee)
    get :edit, params: { id: '42', factory_id: '37' }

    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
    assert_response :success
  end

  def test_expose_a_newly_create_employee_on_create
    Employee.expects(:build).with(build_parameters({'these' => 'params'})).returns(mock_employee(save: true))
    post :create, params: { factory_id: '37', employee: {these: 'params'} }

    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_update_the_requested_object_on_update
    Employee.expects(:find).with('42').returns(mock_employee)
    mock_employee.expects(:update).with(build_parameters({'these' => 'params'})).returns(true)
    put :update, params: { id: '42', factory_id: '37', employee: {these: 'params'} }

    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_the_requested_employee_is_destroyed_on_destroy
    Employee.expects(:find).with('42').returns(mock_employee)
    mock_employee.expects(:destroy)
    delete :destroy, params: { id: '42', factory_id: '37' }

    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_polymorphic_helpers
    mock_factory.stubs(:class).returns(Factory)

    Employee.expects(:scoped).returns([mock_employee])
    get :index, params: { factory_id: '37' }

    assert @controller.send(:parent?)
    assert_equal :factory, assigns(:parent_type)
    assert_equal :factory, @controller.send(:parent_type)
    assert_equal Factory, @controller.send(:parent_class)
    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_factory, @controller.send(:parent)
  end

  protected

    def mock_factory(stubs={})
      @mock_factory ||= mock(stubs)
    end

    def mock_employee(stubs={})
      @mock_employee ||= mock(stubs)
    end

    def build_parameters(hash)
      ActionController::Parameters.new(hash)
    end
end

class PolymorphicCompanyTest < ActionController::TestCase
  tests EmployeesController

  def setup
    draw_routes do
      resources :employees
    end

    Company.expects(:find).with('37').returns(mock_company)
    mock_company.expects(:employees).returns(Employee)

    @controller.stubs(:resource_url).returns('/')
    @controller.stubs(:collection_url).returns('/')
  end

  def teardown
    clear_routes
  end

  def test_expose_all_employees_as_instance_variable_on_index
    Employee.expects(:scoped).returns([mock_employee])
    get :index, params: { company_id: '37' }

    assert_equal mock_company, assigns(:company)
    assert_equal [mock_employee], assigns(:employees)
  end

  def test_expose_the_requested_employee_on_show
    Employee.expects(:find).with('42').returns(mock_employee)
    get :show, params: { id: '42', company_id: '37' }

    assert_equal mock_company, assigns(:company)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_expose_a_new_employee_on_new
    Employee.expects(:build).returns(mock_employee)
    get :new, params: { company_id: '37' }

    assert_equal mock_company, assigns(:company)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_expose_the_requested_employee_on_edit
    Employee.expects(:find).with('42').returns(mock_employee)
    get :edit, params: { id: '42', company_id: '37' }

    assert_equal mock_company, assigns(:company)
    assert_equal mock_employee, assigns(:employee)
    assert_response :success
  end

  def test_expose_a_newly_create_employee_on_create
    Employee.expects(:build).with(build_parameters({'these' => 'params'})).returns(mock_employee(save: true))
    post :create, params: { company_id: '37', employee: {these: 'params'} }

    assert_equal mock_company, assigns(:company)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_update_the_requested_object_on_update
    Employee.expects(:find).with('42').returns(mock_employee)
    mock_employee.expects(:update).with(build_parameters({'these' => 'params'})).returns(true)
    put :update, params: { id: '42', company_id: '37', employee: {these: 'params'} }

    assert_equal mock_company, assigns(:company)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_the_requested_employee_is_destroyed_on_destroy
    Employee.expects(:find).with('42').returns(mock_employee)
    mock_employee.expects(:destroy)
    delete :destroy, params: { id: '42', company_id: '37' }

    assert_equal mock_company, assigns(:company)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_polymorphic_helpers
    mock_company.stubs(:class).returns(Company)

    Employee.expects(:scoped).returns([mock_employee])
    get :index, params: { company_id: '37' }

    assert @controller.send(:parent?)
    assert_equal :company, assigns(:parent_type)
    assert_equal :company, @controller.send(:parent_type)
    assert_equal Company, @controller.send(:parent_class)
    assert_equal mock_company, assigns(:company)
    assert_equal mock_company, @controller.send(:parent)
  end

  protected

    def mock_company(stubs={})
      @mock_company ||= mock(stubs)
    end

    def mock_employee(stubs={})
      @mock_employee ||= mock(stubs)
    end

    def build_parameters(hash)
      ActionController::Parameters.new(hash)
    end
end

class PolymorphicPhotosTest < ActionController::TestCase
  tests PhotosController

  def setup
    draw_routes do
      resources :photos
    end

    User.expects(:find).with('37').returns(mock_user)
  end

  def teardown
    clear_routes
  end

  def test_parent_as_instance_variable_on_index_when_method_overwritten
    get :index, params: { user_id: '37' }

    assert_equal mock_user, assigns(:user)
  end

  protected

    def mock_user(stubs={})
      @mock_user ||= mock(stubs)
    end
end
