/*global
    Morris
*/

//Class ePuStaInline

function EPuStaInline (element,providerurl,epustaid,from,until,counttype) {
  this.providerurl = providerurl;
  this.epustaid = epustaid;
  this.$element = $(element);
  this.count = "";
  this.counttype = counttype;
  this.state = "";
  this.errortext ="";
  this.from = (isNaN(Date.parse(from)) === false) ? from : "2010-01-01";
  this.until = (isNaN(Date.parse(until)) === false) ? until : new Date().toJSON().substring(0,10);
  this.granularity = "total";
}
EPuStaInline.prototype= {
  constructor: EPuStaInline

  ,requestData: function () {
    this.state="waiting";
    this.render();
    $.ajax({
      method : "GET",
      url : this.providerurl
        + "jsonloader.php?identifier="+this.epustaid
        + "&from=" + this.from + "&until=" + this.until
        + "&formatExtension=xml&granularity=total",
      dataType : "xml",
      context: this
      }).done(function(data) {
        EPuStaInline.receiveData(this, data);
      }).fail(function(e) {
        this.state="error";
        this.errortext="Fehler beim Holen der Daten vom Graphprovider";
        this.render();
        console.log("Fehler beim Holen der Daten vom Graphprovider");
    });
  }

  ,render: function () {
    switch(this.state) {
      case "error":
        this.$element.html("<i class='fas fa-exclamation-triangle' data-toggle='tooltip' title='"+this.errortext+"'></i>");
        break;
      case "waiting":
        this.$element.html("<i class='fas fa-spinner fa-pulse'></i>");
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

EPuStaInline.receiveData = function(epustainline,xml) {

  if (xml) {
    var nodes = $(xml).find("access");
    nodes.each (function () {
      var type=$($(this).children( "type" )[0]).text();
      if (type===epustainline.getCounttype()) {
        var count=$($(this).children( "count" )[0]).text();
        epustainline.setCount(count);
      }
    });
  } else {
    // JSON Loader does not reponse xml if the ID doesn't exsist or never counted
    epustainline.setCount(0);
  }
  epustainline.state="success";
  epustainline.render();
};

//Class ePuStaGraph

function EPuStaGraph (element,providerurl,epustaid,from,until,granularity) {
  this.providerurl = providerurl;
  this.epustaid = epustaid;
  this.$element = $(element);
  this.state = "";
  this.errortext ="";
  this.granularity = (isNaN(this.granularity)) ? "month" : granularity;
  this.from = (isNaN(Date.parse(from)) === false) ? from : "auto";
  this.until = (isNaN(Date.parse(until)) === false) ? until : new Date().toJSON().substring(0,10);
  this.data = [];
  this.barchart = "";
}
EPuStaGraph.prototype= {
  constructor: EPuStaGraph

  ,requestData: function () {
    this.state="waiting";
    this.render();
    $.ajax({
      method : "GET",
      url : this.providerurl
        + "jsonloader.php?identifier="+this.epustaid
        + "&from=" + this.calculateFrom() + "&until=" + this.until
        + "&formatExtension=json&granularity="+this.granularity,
      dataType : "json",
      context: this
      }).done(function(data) {
        EPuStaGraph.receiveData(this, data);
      }).fail(function(e) {
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
        html+="<i class='fas fa-exclamation-triangle' data-toggle='tooltip' title='"+this.errortext+"'/>";
        html+=this.errortext;
        html+="</div>";
        this.$element.html(html);
        break;
      case "waiting":
        this.$element.html("<div style='font-size: 5em;text-align:center;'> <i class='fas fa-spinner fa-pulse'></i> </div>");
        break;
      case "success":
        console.log("Render barchart");
        this.$element.html(" <div id='epustaGraphic' style='height:80%'> </div> " +
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
        var epustaElement = this;
        $("input[name='granularity'][value='"+this.granularity+"']").attr("checked","checked");  // Check the right radiobutton
        $("input[name='granularity']").on("change",null,function() {
          epustaElement.granularity=this.value;
          epustaElement.from="auto";
          epustaElement.requestData();
        });
        this.barchart = new Morris.Bar({
          element: "epustaGraphic",
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
      var today=new Date();
      var from=new Date();
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

EPuStaGraph.receiveData = function(epustagraph,json) {
  if (json) {
    epustagraph.data=json.entries;
    epustagraph.state="success";
  } else {
    epustagraph.state="error";
    epustagraph.errortext="Keine Zugriffsdaten vorhanden";
  }
  epustagraph.render();
};

// End Class ePuStaGraph

$(document).ready(function() {
  $('[data-epustaelementtype]').each(function(index, element) {
    var epustaElementtype=$(element).data('epustaelementtype');
    var epustaProviderurl=$(element).data('epustaproviderurl');
    var epustaIdentifier=$(element).data('epustaidentifier');
    var epustaCounttype=$(element).data('epustacounttype');
    var epustaFrom=$(element).data('epustafrom');
    var epustaUntil=$(element).data('epustauntil');
    var epustaElement;
    if (epustaElementtype == "ePuStaInline" ) {
      epustaElement = new EPuStaInline(element,epustaProviderurl,epustaIdentifier,epustaFrom,epustaUntil,epustaCounttype);
      epustaElement.requestData();
    }
    if (epustaElementtype === "EPuStaGraph" ) {
      epustaElement = new EPuStaGraph(element,epustaProviderurl,epustaIdentifier,epustaFrom,epustaUntil);
      $('#epustaGraphModal').on('shown.bs.modal', function () {
        epustaElement.requestData();
      });
    }

  });
});
