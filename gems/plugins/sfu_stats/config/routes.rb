CanvasRails::Application.routes.draw do
  match "/sfu/stats" => "stats#index", via: :get
  match "/sfu/stats/restricted" => "stats#restricted", via: :get
  match "/sfu/stats/courses(/:term_id(.:format))" => "stats#courses", :defaults => { :term => nil, :format => "html" }, via: :get
  match "/sfu/stats/enrollments(/:term_id(.:format))" => "stats#enrollments", :defaults => { :term => nil, :format => "html" }, via: :get
end
