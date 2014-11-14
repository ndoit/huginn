Ryan's Development
===

Report Images
---
> each one of these methods can get broken down for testing.

First step is we're gonna figure out how the program works right now. When we hit the url `'/browse/report'` we go to where? Let's check `rake routes`

```ruby
browse GET  /browse(.:format)                     guide#index
       GET  /browse/:selected_resources(.:format) guide#index
```

We see we get sent to the guides controller and the #index action

```ruby
# app/controllers/guide_controller.rb
# interesting to note that 'guide_controller' is singular.

class GuideController < ApplicationController

before_filter :node_types

def node_types

  @node_types = [ 'report', 'term' ]

  @report_roles = []
  if current_user
    @report_roles = Muninn::SecurityRoleAdapter.all.select { |k| k.report_role? && (current_user.has_role? k.name) }
  end
end

def index
  if params.has_key?(:selected_resources)
    params[:selected_resources] = params[:selected_resources].singularize
  end
end
```

We see that `def node_types` does two things. (bad- methods should only do one thing).

Let's see if we can split this into two methods.

```ruby
# app/controllers/guide_controller.rb
class GuideController < ApplicationController

  before_filter :node_types, :report_roles

  def node_types
    @node_types = [ 'report', 'term' ]
  end

  def report_roles
    @report_roles = []
    if current_user
      @report_roles = Muninn::SecurityRoleAdapter.all.select do |k|
        k.report_role? && (current_user.has_role? k.name)
      end
    end
  end
```

Success. I also broke up `report_roles` into more lines for better readability.

`node_types` creates a variable `@node_types` and stores 'reports' and 'terms' in it as an array. Looking through the rest of the report_controller I don't see this variable being used again. I find it in models in a muninn custom search adapter.

```ruby
# app/models/muninn/custom_search_adapter
class Muninn::CustomSearchAdapter

  attr_reader :selected_node_types, :results

  def initialize(args)
    @node_types = [ 'report', 'term', 'office' ]
    @muninn_result = query_muninn( args[:q], args[:page] )
    @page = args[:page]
    @selected_node_types = selected_resource_array( args )
    self
  end

```

But, it's being defined again. Maybe I can get rid of it in the guide index. Only other place I find it is in the view

```html
<!-- app/views/guide/search.html.erb -->
<div class="row">

    <!-- SIDEBAR -->
    <dl class="left-sidebar small-2 column">

      <% @node_types.each_with_index do |type_name,index| %>
        <div class="data-type-label-container toggleable-data-type-label-container">
          <div>
            <div class="data-type-toggle">
              <div data-resource-name="<%= type_name %>" class="toggle_light toggle_on
                <%= "toggle_off" if !@selected_node_types.include? type_name %>">
                <%= check_box_tag '', '', (@selected_node_types.include? type_name) %>
              </div>
            </div>
            <div class="data-type-label"><%= type_name %></div>
            <div class="data-type-count"><%= @resource_count_hash[type_name] || 0 %></div>
          </div>
        </div>
      </br>

```
Aha. I believe it's being defined in all the guide controller actions/thus the views too/ at once and then being shown on the left side as the counter for all the terms and reports in the results. Commenting it out results in browser console errors so it is being used.

Back to `node_types`. Second thing it does is check and stores the user roles.  Because the user can currently have more roles than muginn knows about, we check if they both exist. I'm still not clear on this. But, its not critical for pics so I'll move on.


Onto the #index action

```ruby
# app/controllers/guide_controller.rb

  def index
    if params.has_key?(:selected_resources)
      params[:selected_resources] = params[:selected_resources].singularize
    end
  end
```

Index is checking if the URL has anything after /browse. If it does, params have been singularized. so terms = term and reports = report. What does defining the params signify for the app? And in more basic coding sense what happens when I explicitly define the params? Does rails magic automatically go to the params view? I don't think so. That wouldn't make sense. As far as I'm aware params is a term for the json/data being sent down from the view layer. As well as the `:id` in the URI for things like `/users/34/show`

Then onto the view

First let's see the template that gets formed in the layout folder

```html
<!-- app/views/layouts/application.html.erb -->
  <body>

    <nav class="skip-links">
      <ul>
        <li><a href="#content" accesskey="C" title="Skip to content = C">Skip To Content</a></li>
        <li><a href="#nav" accesskey="S" title="Skip to navigation = S">Skip To Navigation</a></li>
      </ul>
    </nav>

    <header id="header" role="banner" class="site-header">
      <div class="beta_banner">
        <%= image_tag "beta_corner_banner.png" %>
      </div>
      <nav class="brandbar theme-bb-lightgray">
        <div class="row">
          <ul class="large-12 columns">
            <li class="dept-nd"><a href="http://www.nd.edu">University <i>of</i> Notre Dame</a></li>
            <li class="dept dept-ooit"><a href="http://oit.nd.edu">Office <i>of</i> Information Technologies</a></li>
           </ul>
        </div>
      </nav>


      <%= render "shared/top_bar" %>
    </header>

    <main id="content" class="site-content" role="main">
        <%= yield %>
    </main>

    <footer id="footer" class="site-footer row" role="contentinfo">
      <div class="large-12 columns">
        <div class="footer-inner">
          <div class="vcard">
            <p class="copyright url fn org">
              <a href="http://www.nd.edu/copyright/">Copyright</a> &copy; <%= Time.now.year %>
              <a href="http://www.nd.edu" class="org">University of Notre Dame</a>
            </p>
            <p class="contact-info adr">
              <span class="address"><span class="street-address">200 OIT Center</span>, <span class="locality">Notre Dame</span>, <span class="region" title="Indiana">IN</span> <span class="postal-code">46556</span></span>
              <span class="tel"><span class="type">Phone</span> 574-631-7770</span>
              <span class="email"><a href="mailto:ES-DECISION-SUPPORT@LISTSERV.ND.EDU">ES-DECISION-SUPPORT@LISTSERV.ND.EDU</a></span>
            </p>
            <a href="http://www.nd.edu" class="ndmark"><img src="//www.nd.edu/assets/images/marks/blue/ndmark300.png" alt="University of Notre Dame"></a>
          </div>
        </div>
      </div>
    </footer>

    <%= javascript_include_tag "application" %>
  </body>
</html>

```

First thing in this application is the nav-links which I cant seem to find in the render. After that is the grey bar which is always present at the top of the page. Second is a render link to the shared nav bar. Past that is the yield command for the rest of the views.

Next is the guide/index.html page being rendered in the 'yield' area of the main body.

```html
<!-- app/views/guide/index.html.erb -->

<div class="row">
	<div class="large-2 columns">&nbsp;</div>
	<div class="large-10 columns">
		<%= text_field_tag "search1" %>
	</div>
</div>
<div class="row">
  <div class="large-12 columns" >
     <div id="search_results">
       <div class="loading_bar">
	       	<% if params.has_key?(:selected_resources)%>
	       		<input type="hidden" id="initial_selected_resources" value="<%= params['selected_resources']%>">
       		<% end %>
        	<%= image_tag "ajax-loader.gif" %>
       </div>
     </div>
   </div>
 </div>
```

In the index we can see the search bar and the loader bar gif. This seems to tell me that most of the rest of the action is occuring in AJAX. Good news is there's only two javascript files. Let's first hunt in guide.js

So. After much hunting and about a days worth of working through the javascript, it is indeed in guide.js.

A couple of things are going on but, the main request is right here

```javascript
function executeFilter() {
  var searchURL = getSearchURL(1)
  console.log(searchURL)
  displayLoading()

  $('#search_results').load( searchURL, function() {
    highlightSearchString()
    bindInfiniteScrollBehavior()
  } )
}
```

A couple things are happening here. First let's jump ahead and look at the actual request.

```javascript
$('#search_results').load( searchURL, function() {
  highlightSearchString()
  bindInfiniteScrollBehavior()
} )
```
This could probably be refactored into it's own method. But later. So a little refresher, the `.load` jquery method accepts up to 3 parameters- the URL controller route, a data object being sent down, and a callback response. In this example it's only using 2, the URL route the request will be sent to, and the callback function on response.  
So depending on which URL gets sent determines which controller#action is perfomed. Because we're displaying our searchURL in `console.log(searchURL)` let's see which one is sent when I click report gallery button.

`/guide_search?selected_resources=report`

Now, I'm a little worried because I believe this gets sent back down to the guide controller and I'll lose it again. But let's check the routes

`guide_search GET    /guide_search(.:format)                    guide#search`

Ok. So it does go down to the guidecontroller#search action. Let's see it.

```ruby
def search
  logger.debug("Querying Muninn...")

  params[:page] ||= 1


  mcsa = Muninn::CustomSearchAdapter.new( params )

  mcsa.filter_results

  @results = mcsa.results
  @muninn_result = mcsa.raw_result
  @selected_node_types = mcsa.selected_node_types  # should the mcsa do this
  @resource_count_hash = mcsa.resource_count_hash

  if ( params[:page].to_i > 1 )
    render partial: "partial_search", locals: { results: @results || [] }, layout: false
  else
    render html: "search", layout: false
  end
end
```

First thing it's doing is checking the params. Upon checking the development logs outputs

```ruby
Started GET "/guide_search?selected_resources=report" for 127.0.0.1 at 2014-11-06 15:26:57 +0000
Processing by GuideController#search as HTML
  Parameters: {"selected_resources"=>"report"}
Existing local CAS session detected for "rsnodgra". Previous ticket "ST-1332680-7LbxLCyCJX0ca7uZlN2b-cas" will be re-used.
cas_proxy_params ********************* :
Querying Muninn...
  Rendered reports/_partial_search.html.erb (30.8ms)
  Rendered guide/_partial_search.html.erb (243.1ms)
  Rendered guide/search.html.erb (455.5ms)
Completed 200 OK in 2223ms (Views: 760.7ms)
```

So we see that the params is just a hash `{"selected_resources"=>"report"}`. So the line `params[:page] ||= 1` I'm a little unclear. Let's try it in a console
```ruby
hash = {"selected_resources" => "report"}
# => {"selected_resources"=>"report"}
hash[:page] ||= 1
# => 1
hash
# => {"selected_resources"=>"report", :page=>1}

###########

hash = {"selected_resources" => "report", :page => 3}
# => {"selected_resources"=>"report", :page => 3}
hash[:page] ||= 1
# => {"selected_resources"=>"report", :page=>2}
hash
# => {"selected_resources"=>"report", :page=>2}

```

I know `||=` is a ruby operator that basicallly means if `:page` doesn't exist, create it. Otherwise, leave it alone. I think this is for the infinite scroll behavior. It'll check which page you're on by looking at the params and then load the next batch of results.

```ruby
mcsa = Muninn::CustomSearchAdapter.new( params )
mcsa.filter_results
```

---

Ok so now we're onto the muninn adapters.

```ruby
class Muninn::CustomSearchAdapter

  attr_reader :selected_node_types, :results

  def initialize(args)
    @node_types = [  'report', 'term', 'office' ]
    @muninn_result = query_muninn( args[:q], args[:page] )
    @page = args[:page]
    @selected_node_types = selected_resource_array( args )
    self
  end
```

There's `@node_types` again! `@muninn_result` has `query_muninn` method lets look at that.

```ruby
def query_muninn( query_string, page_number )
  search_string = create_search_string( query_string )
  custom_query(search_string, page_number, 15 )
end
```

And another method

```ruby
def create_search_string(search_s)
 if !search_s.blank?
   json_string ='{ "query" : { "query_string" : {"query" :  "' + "#{search_s}" + '","default_operator": "and"}},"aggs" : {"type" : {"terms" : { "field" :  "_type" }}},"from":"0","size":"999" }'
 else
     json_string = '{ "query" : { "query_string" : {"query" : "*","default_operator": "and"}},"aggs" : {"type" : {"terms" : { "field" :  "_type" }}},"from":"0","size":"999" }'
  end

  #puts "query string: " + json_string
  json_string
end
```

So I've found that if I don't enter anything into the search bar, I get the params I've found. If I do enter something, i get something like
```ruby
  Parameters: {"selected_resources"=>"report,term", "q"=>"degree"}
```

I don't like that `!search_s.blank?` check. There's a well written blog post [here](http://www.railstips.org/blog/archives/2008/12/01/unless-the-abused-ruby-conditional/) that explains why we don't use unless in place of if statements.

```ruby
def create_search_string(search_s)
  if search_s.blank?
    json_string = '{ "query" : { "query_string" : {"query" : "*","default_operator": "and"}},"aggs" : {"type" : {"terms" : { "field" :  "_type" }}},"from":"0","size":"999" }'
  else
    json_string ='{ "query" : { "query_string" : {"query" :  "' + "#{search_s}" + '","default_operator": "and"}},"aggs" : {"type" : {"terms" : { "field" :  "_type" }}},"from":"0","size":"999" }'
  end
  #puts "query string: " + json_string
  json_string
end
```

Just a simple flip and much better.

After our search_string definition, the next step is
```ruby
custom_query(search_string, page_number, 15 )
```

Alright find the custom_query method

```ruby
def custom_query(json_string, page, per_page )
  muninn_host = ENV["muninn_host"]
  muninn_port = ENV["muninn_port"]

  muninn_response = HTTParty.get("http://#{muninn_host}:#{muninn_port}/search/custom/query",
  { :body => json_string, :headers => { 'Content-Type' => 'application/json'} })

  output_string= ActiveSupport::JSON.decode(muninn_response.body.to_json)

  results= extract_results(output_string)

 end
 ```

 There's a lot of jargon in here but
 ```ruby
 muninn_host = ENV["muninn_host"]
 muninn_port = ENV["muninn_port"]
 ```
 is checking the secret keys for the muninn access points.

 ```ruby
 muninn_response = HTTParty.get("http://#{muninn_host}:#{muninn_port}/search/custom/query",
 { :body => json_string, :headers => { 'Content-Type' => 'application/json'} })
 ```
is the actual request being sent to muninn. This is a get request with the json_string we just defined.

```ruby
output_string= ActiveSupport::JSON.decode(muninn_response.body.to_json)
```
And here is the response back. Muninn sends a response back as JSON but, ruby interprets it as a string. It has to be coded back into JSON before we can start playing with it.

```ruby
[vagrant@localhost ~]$ curl 'http://localhost:3000/terms/active'
{"message":"term not found.","success":false,"validated_user":null,"raci_matrix":{}}[vagrant@localhost ~]$ curl 'http://localhost:3000/terms/Active'
{"message":"term not found.","success":false,"validated_user":null,"raci_matrix":{}}[vagrant@localhost ~]$ curl 'http://localhost:3000/terms/Active Student'
[vagrant@localhost ~]$ curl 'http://localhost:3000/terms/Active%20Student'
{"term":{"created_date":"2014-10-23T20:54:15Z","modified_date":"2014-10-28T19:01:11Z","created_by":"","modified_by":"","id":118,"definition":"An individual who has been confirmed by an admitting office (or other admitting authority), as recorded by the University Registrar, is considered an active student until he or she:\n\n● Graduates (if degree-seeking)\n● Completes the academic term (if non degree-seeking)\n● Withdraws or is dismissed by the University \n● Fails to enroll for a spring or fall academic term (unless granted a leave of absence by a Dean)\n","source_system":"Banner","possible_values":"N/A","notes":"Students who withdraw or are dismissed during an academic term may be considered active for that academic term, at the discretion of the student’s dean.\n\nDuring the Fall and Spring academic term, students have up until the sixth day of classes to complete the roll call process and students who fail to enroll are inactivated, unless on leave.  Therefore, the use of current term active student data during the first two weeks of an academic term should be done judiciously.\n","data_sensitivity":"SELECT *\nFROM SGBSTDN\nWHERE Status = ‘AS’\n","data_availability":"Data is available by term from Fall 1982 to the present\n\n","name":"Active Student"},"success":true,"stakeholders":[],"reports":[],"validated_user":null,"raci_matrix":{}}[vagrant@localhost ~]$
```

```ruby
@results = [{"id"=>4493, "type"=>"report", "score"=>1.0, "data"=>{"id"=>4493, "datasource"=>"NA", "data_last_updated"=>nil, "description"=>"<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum</p>\n<p><br /><br /></p>", "embedJSON"=>"{\"width\": \"500\", \"height\" : \"500\",\"name\":\"Sales/2013SalesGrowth\",\"tabs\":\"no\"}", "report_type"=>"Tableau", "thumbnail_uri"=>nil, "name"=>"Yolo Swag", "domain_tags"=>[], "bus_process_tags"=>[], "offices"=>[], "terms"=>[], "security_roles"=>[]}, "sort_name"=>"Yolo Swag"}]

@results[0]["type"] == "report"
```

We need to parse this response into something useful. I needed a refresher on hash syntax so here's my example

```ruby
apples = Hash.new
apples[:golden_delicious] = { :type => "sweet", :color => "green", :forbidden => true }
apples[:red_delicious] = { :type => "sweet", :color => "red", :forbidden => true}
apples[:granny_smith] = { :type => "tart", :color => "green", :forbidden => false}
apples[:macintosh] = { :type => "mild", :color => "red", :forbidden => true}
apples[:gala] = { :type => "sweet", :color => "red", :forbidden => true}
# {:gala=>{:type=>"sweet", :forbidden=>true, :color=>"red"}, :red_delicious=>{:type=>"sweet", :forbidden=>true, :color=>"red"}, :granny_smith=>{:type=>"tart", :forbidden=>false, :color=>"green"}, :golden_delicious=>{:type=>"sweet", :forbidden=>true, :color=>"green"}, :macintosh=>{:type=>"mild", :forbidden=>true, :color=>"red"}}
```

We created a hash similar to the type found above. A hash where each term was defined by its name then a hash with all the parameters inside it.

```ruby
apples[:golden_delicious][:type]
# => "sweet"
apples[:red_delicious][:type]
# => "sweet"
```

So we can query inside the individual hashes by going 2 params deep. Now let's see if we can select certain hashes

```ruby
nonforbidden = Array.new
nonforbidden = apples.each do { |k, v|  
  if v[:forbidden] == false
    nonforbidden << k
  end
end
# => [:granny_smith]

puts nonforbidden.singleton_class
# => #<Class:#<Array:0x)07ff2b081148>>

puts nonforbidden[:gala]
# => {:type=>"sweet", :color=>"red", :forbidden=>true}
```
This isnt working. for some reason, it's putting in all of the hashes

Let's try something else

```ruby
nonforbidden = apples.select { | k, v | v[:forbidden] == false }
# => [[:granny_smith, {}]]
```

Now we only have the one that we want

---

In a seperate file I've got a 
