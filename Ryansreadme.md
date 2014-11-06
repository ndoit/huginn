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
