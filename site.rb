require "sinatra"
require "./lib/database"

class Site < Sinatra::Base
  set :method_override, true # Allow use of PUT/DELETE by using "_method" param

  def db
    @db ||= TaskList::Database.new("tasklist.db")
  end

  def task_from_params
    TaskList::Task.new(nil, params[:name],
                       params[:description].empty? ? nil : params[:description], nil)
  end

  def current_task
    @current_task ||= db.find_task(params[:task_id].to_i)
  end

  get "/" do
    @tasks = db.find_all_tasks
    erb :index
  end

  get "/new" do
    erb :new
  end

  post "/" do
    task = task_from_params
    db.create_task(task)

    redirect to "/"
  end

  get "/:task_id/delete" do
    @task = current_task
    erb :delete
  end

  delete "/:task_id" do
    db.delete_task(current_task) if current_task
    redirect to "/"
  end

  get "/:task_id/complete" do
    @task = current_task
    erb :complete
  end

  put "/:task_id/complete" do
    db.complete_task(current_task) if current_task
    redirect to "/"
  end
end
