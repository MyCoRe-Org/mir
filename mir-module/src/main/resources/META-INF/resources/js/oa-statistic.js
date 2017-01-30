//Class OASInline

function OASInline (element,providerurl,oasid,from,until,counttype) {
  this.providerurl = providerurl;
  this.oasid = oasid;
  this.$element = $(element);
  this.count = "";
  this.counttype = counttype;
  this.state = "";
  this.errortext ="";
  this.from = (isNaN(Date.parse(from)) === false) ? from : "2010-01-01";
  this.until = (isNaN(Date.parse(until)) === false) ? until : new Date().toJSON().substring(0,10); 
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
  
  if (xml) {
    nodes = $(xml).find("access");
    nodes.each (function () {
      type=$($(this).children( "type" )[0]).text();
      if (type==oasinline.getCounttype()) {
        count=$($(this).children( "count" )[0]).text();
        oasinline.setCount(count);
      }
    });
  } else {
    // JSON Loader does not reponse xml if the ID doesn't exsist or never counted
    oasinline.setCount(0);
  }
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
  this.from = (isNaN(Date.parse(from)) === false) ? from : "auto";
  this.until = (isNaN(Date.parse(until)) === false) ? until : new Date().toJSON().substring(0,10);
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
        + "&from=" + this.calculateFrom() + "&until=" + this.until
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
        var html='<div style="with:100%;text-align:center;">';
        html+="<i class='fa fa-exclamation-triangle' data-toggle='tooltip' title='"+this.errortext+"'/>";
        html+=this.errortext;
        html+="</div>";
        this.$element.html(html);
        break;
      case "waiting":
        this.$element.html("<div style='font-size: 5em;text-align:center;'> <i class='fa fa-spinner fa-pulse'></i> </div>");
        break;
      case "success":
        console.log("Render barchart");
        this.$element.html(" <div id='oasGraphic' style='height:80%'> </div> " +
            "<div style='text-align:center'> " +
            "  nach " +
            "  <input type='radio' id='grday' name='granularity' value='day' /> " +
            "  <label for='grday'>Tag</label> " +
            "  <input type='radio' id='grweek' name='granularity' value='week'/> " +
            "  <label for='grweek'>Woche</label> " +
            "  <input type='radio' id='grmonth' name='granularity' value='month'/> " +
            "  <label for='grmonth'>Monat</label> " +
            "</div> " 
        );
        var oasElement = this;
        $("input[name='granularity'][value='"+this.granularity+"']").attr("checked","checked");  // Check the right radiobutton
        $("input[name='granularity']").on("change",null,function() {
          oasElement.granularity=this.value;
          oasElement.from="auto";
          oasElement.requestData();
        });
        new Morris.Bar({
          element: "oasGraphic",
          data: this.data,
          xkey: 'date',
          ykeys: ['counter','counter_abstract'],
          labels: ['Volltextzugriffe','Metadatenansichten'],
          hideHover:true
        });
        break;
      default:
        this.$element.text("");
    }
  }
  
  ,calculateFrom: function () {
    if (this.from == "auto") {
      today=new Date();
      from=new Date();
      switch (this.granularity) {
        case "day":
          from.setDate(today.getDate() - 14);
          break;
        case "week":
          from.setDate(today.getDate() - 77);
          break;
        case "month":
          from.setMonth(today.getMonth() - 12);
          break;
        default:
          from.setMonth(today.getMonth() - 12);
      }
      return from.toJSON().substring(0,10);  
    } else {
      return this.from;
    }
  } 
};

OASGraph.receiveData = function(oasgraph,json) {
  if (json) {
    oasgraph.data=json.entries;
    oasgraph.state="success";
  } else {
    oasgraph.state="error";
    oasgraph.errortext="Keine Zugriffsdaten vorhanden";
  }
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
      var oasElement = new OASInline(element,oasProviderurl,oasIdentifier,oasFrom,oasUntil,oasCounttype);
      oasElement.requestData();
    }
    if (oasElementtype == "OASGraph" ) {
      var oasElement = new OASGraph(element,oasProviderurl,oasIdentifier,oasFrom,oasUntil);
      $('#oasGraphModal').on('shown.bs.modal', function () {
        oasElement.requestData();
      });
    }  
    
  });
});
