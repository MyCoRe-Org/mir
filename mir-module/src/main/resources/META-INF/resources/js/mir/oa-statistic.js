//Class OASInline

function OASInline (element,providerurl,oasid,from,until,counttype) {
  this.providerurl = providerurl;
  this.oasid = oasid;
  this.$element = $(element);
  this.count = "";
  this.counttype = counttype;
  this.state = "";
  this.errortext ="";
  this.from = (isNaN(Date.parse(from)) == false) ? from : "2010-1-1";
  this.until = (isNaN(Date.parse(until)) == false) ? until : new Date().toJSON().substring(0,10); 
  this.granularity = "total";
};

OASInline.prototype= {
  constructor: OASInline
  
  ,requestData: function () {
    this.state="waiting";
    this.render();
    $.ajax({
		method : "GET",
		url : this.providerurl 
		    + "jsonloader.php?identifier="+this.oasid
		    + "&from=" + this.from + "&until=" + this.until
		    + "&formatExtension=xml&granularity=total",
		dataType : "xml",
		context: this
	}).done(function(data) {
		OASInline.receiveData(this, data)
	}).error(function(e) {
	    this.state="error";
	    this.errortext="Fehler beim Holen der Daten vom Graphprovider";
	    this.render();
		console.log("Fehler beim Holen der Daten vom Graphprovider");
	});
  }
  
  ,render: function () {
    switch(this.state) {
      case "error":
        this.$element.html("<i class='fa fa-exclamation-triangle' data-toggle='tooltip' title='"+this.errortext+"'></i>");
        break;
      case "waiting":
        this.$element.html("<i class='fa fa-spinner fa-pulse'></i>");
        break;
      case "success":
        this.$element.text(this.count);
        break;
      default:
        this.$element.text("");
    }
  }
  
  ,setCount: function (count) {
    this.count=count;
  }
  
  ,getCounttype: function (counttype) {
    return(this.counttype);
  }
};

OASInline.receiveData = function(oasinline,xml) {
  
  nodes = $(xml).find("access");
  nodes.each (function () {
    type=$($(this).children( "type" )[0]).text();
    if (type==oasinline.getCounttype()) {
      count=$($(this).children( "count" )[0]).text();
      oasinline.setCount(count);
    }
  });
  oasinline.state="success";
  oasinline.render();
};

//Class OASGraph

function OASGraph (element,providerurl,oasid,from,until,granularity) {
  this.providerurl = providerurl;
  this.oasid = oasid;
  this.$element = $(element);
  this.state = "";
  this.errortext ="";
  this.granularity = (isNaN(this.granularity)) ? "month" : granularity;
  this.from = (isNaN(Date.parse(from)) == false) ? from : "2010-1-1";
  this.until = (isNaN(Date.parse(until)) == false) ? until : new Date().toJSON().substring(0,10);
  this.data = [];
};

OASGraph.prototype= {
  constructor: OASGraph
  
  ,requestData: function () {
    this.state="waiting";
    this.render();
    $.ajax({
		method : "GET",
		url : this.providerurl 
		    + "jsonloader.php?identifier="+this.oasid
		    + "&from=" + this.from + "&until=" + this.until
		    + "&formatExtension=json&granularity="+this.granularity,
		dataType : "json",
		context: this
	}).done(function(data) {
		OASGraph.receiveData(this, data)
	}).error(function(e) {
	    this.state="error";
	    this.errortext="Fehler beim Holen der Daten vom Graphprovider";
	    this.render();
		console.log("Fehler beim Holen der Daten vom Graphprovider");
	});
  }
  
  ,render: function () {
    switch(this.state) {
      case "error":
        this.$element.html("<i class='fa fa-exclamation-triangle' data-toggle='tooltip' title='"+this.errortext+"'></i>");
        break;
      case "waiting":
        this.$element.html("<i class='fa fa-spinner fa-pulse'></i>");
        break;
      case "success":
        console.log("Render barchart");
        this.$element.html("");
        new Morris.Bar({
          element: "oasGraph",
          data: this.data,
          xkey: 'date',
          ykeys: ['counter'],
          labels: ['Downloads'],
          hideHover:true
        });
        break;
      default:
        this.$element.text("");
    }
  }
  
  ,setCount: function (count) {
    this.count=count;
  }
  
  ,getCounttype: function (counttype) {
    return(this.counttype);
  }
};

OASGraph.receiveData = function(oasgraph,json) {
  //oasgraph.parseData.
  oasgraph.data=json.entries;
  oasgraph.state="success";
  oasgraph.render();
};

// End Class OASGraph

$(document).ready(function() {
  $('[data-oaselementtype]').each(function(index, element) {
    oasElementtype=$(element).data('oaselementtype');
    oasProviderurl=$(element).data('oasproviderurl');
    oasIdentifier=$(element).data('oasidentifier');
    oasCounttype=$(element).data('oascounttype');
    oasFrom=$(element).data('oasfrom');
    oasUntil=$(element).data('oasuntil');
    if (oasElementtype == "OASInline" ) {
      oasElement = new OASInline(element,oasProviderurl,oasIdentifier,oasFrom,oasUntil,oasCounttype);
      oasElement.requestData();
    }
    if (oasElementtype == "OASGraph" ) {
      oasElement = new OASGraph(element,oasProviderurl,oasIdentifier,oasFrom,oasUntil);
      $('#oasGraphModal').on('shown.bs.modal', function () {
        oasElement.requestData();
      });
    }  
    
  });
});
