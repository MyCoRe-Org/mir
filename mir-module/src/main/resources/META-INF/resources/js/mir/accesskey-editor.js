const API_URL = webApplicationBaseURL + "api/v2/objects/";
class EventEmitter {
  constructor() {
    this._events = {};
  }
  on(evt, listener) {
    (this._events[evt] || (this._events[evt] = [])).push(listener);
    return this;
  }
  emit(evt, arg) {
    (this._events[evt] || []).slice().forEach(lsn => lsn(arg));
  }
}
class TableModel extends EventEmitter {
  constructor(data) {
    super();
    this._data = data;
  }
  get data() {
    return this._data;
  }
  set data(data) {
    this._data = data;
      this.emit("dataChanged", data);
  }
  updateRow(index, data) {
    this._data[index] = data;
    this.emit("rowUpdated", {
      "index": index, 
      "data": data
    });
  }
  deleteRow(index) {
    this._data.splice(index, 1);
    this.emit("rowDeleted", index);
  }
  addRow(data) {
    this._data.push(data);
    this.emit("rowAdded", {
      "index": this._data.length - 1,
      "data": data
    });
  }
  getDataAt(index) {
    return this._data[index];
  }
}
class PaginatorModel extends EventEmitter {
  constructor(itemCount, itemLimit, pageOffset) {
    super();
    this._itemCount = itemCount;
    this._itemLimit = itemLimit;
    this._pageOffset = pageOffset;
  }
  get itemCount() {
    return this._itemCount;
  }
  set itemCount(itemCount) {
    this._itemCount = itemCount;
  }
  get itemOffset() {
    return this._pageOffset * this._itemLimit;
  }
  get pageOffset() {
    return this._pageOffset;
  }
  set pageOffset(pageOffset) {
    this._pageOffset = pageOffset;
  }
  get itemLimit() {
    return this._itemLimit;
  }
  get currentPageCount() {
    if (this._itemCount == 0) {
      return 1;
    }
    return Math.ceil(this._itemCount / this._itemLimit);
  }
  set itemLimit(itemLimit) {
    if (itemLimit != this._itemLimit) {
      this._itemLimit = itemLimit;
      this.emit("itemLimitChanged", itemLimit);
    }
  }
}
class MIRAccessKeyEditor {
  constructor(client) {
    this._client = client;
    this._init();
  }
  _init() {
    this._tableModel = new TableModel([]);
    const itemLimit = 8;
    this._paginatorModel = new PaginatorModel(0, itemLimit, 0);
    this._initTableHandler();
    this._initPaginationHandler();
    this._initTable(itemLimit);
    this._client.getKeys(0, itemLimit, (error, result) => {
      if (!error) {
        this._paginatorModel.itemCount = result["totalResults"];
        this._tableModel.data = result["items"];
        $("#spinner").hide();
        $("#key-table").show();
        $("#paginator-div").show();
        $("#error-alert-div").text("");
        $("#new-btn").show();
      } else {
        $("#spinner").hide();
        $("#error-alert-div").show();
      }
    });
    this._initModalHandler();
  }
  _initTableHandler() {
    const handleDataChanged = (data) => {
      this._renderTable(this._paginatorModel.itemOffset, data);
      this._renderPagination();
    };
    const handleRowDeleted = (index) => {
      const itemLimit = this._paginatorModel.itemLimit;
      const pageOffset = this._paginatorModel.pageOffset;
      if ((this._tableModel.data.length == 0 && pageOffset > 0)
        || (this._tableModel.data.length == itemLimit - 1 
        && this._paginatorModel.currentPageCount - 1 != pageOffset)) {
        if (pageOffset > 0) {
          this._paginatorModel.pageOffset -= 1;
        }
        this._updateTableModel(this._paginatorModel.itemOffset, itemLimit);
      } else {
        this._paginatorModel.itemCount -= 1;
        if (this._tableModel.data.length == 0) {
          this._renderRow(index);
        } else {
          this._renderTable(this._paginatorModel.itemOffset, this._tableModel.data);
        }
      }
    }
    const handleRowAdded = (result) => {
      const data = result.data;
      this._paginatorModel.itemCount += 1;
      if (this._tableModel.data.length > this._paginatorModel.itemLimit) {
        this._paginatorModel.pageOffset += 1;
        const newData = [data];
        this._tableModel.data = newData;
      } else {
        const index = result.index;
        this._renderRow(index, data, this._paginatorModel.itemOffset);
      }
    }
    const handleRowUpdated = (result) => {
      const index = result.index;
      const data = result.data;
      this._renderRow(index, data);
    }
    this._tableModel.on("rowUpdated", handleRowUpdated);
    this._tableModel.on("rowAdded", handleRowAdded);
    this._tableModel.on("dataChanged", handleDataChanged);
    this._tableModel.on("rowDeleted", handleRowDeleted);
  }
  _fetchI18n(system) {
    let result = "";
    $.ajax({
      url: webApplicationBaseURL + "rsc/locale/translate/" + $("html").attr("lang") + "/" + system + ".accesskey*",
      type: 'GET',
      success: function (data) {
        result = data;
      },
      async: false
    });
    return result;
  }
  _getI18n(code) {
    if (code.startsWith("mcr")) {
      if (this._i18nMCR === undefined) {
        this._i18nMCR = this._fetchI18n("mcr");
      }
      if (this._i18nMCR !== undefined && this._i18nMCR.hasOwnProperty(code)) {
        return this._i18nMCR[code];
      }
    } else if (code.startsWith("mir")) {
      if (this._i18nMIR === undefined) {
        this._i18nMIR = this._fetchI18n("mir");
      }
      if (this._i18nMIR !== undefined && this._i18nMIR.hasOwnProperty(code)) {
        return this._i18nMIR[code];
      }
    }
    return "???" + code + "???";
  }
  _updateTableModel(itemOffset, itemLimit) {
    $("#spinner").show();
    $("#error-alert-div").hide();
    this._client.getKeys(itemOffset, itemLimit, (error, result) => {
      if (!error) {
        this._paginatorModel.itemCount = result["totalResults"];
        this._tableModel.data = result["items"];
        $("#spinner").hide();
      } else {
        const errorString = this._handleError(error)
        $("#error-alert-div").text(errorString);
        $("#error-alert-div").show();
        $("#spinner").hide();
      }
    });
  };
  _initModalHandler() {
    const handleShowEditModal = (event) => {
      const data = $(event.relatedTarget).data();
      if (data.index != undefined) {
        const accessKey = this._tableModel.getDataAt(data.index);
        $("#id-input").val(accessKey.value);
        $("#id-div").show();
        $("#type-input").val(accessKey.type);
        $("#value-div").hide();
        $("#comment-textarea").val(accessKey.comment);
        $("#creator-input").show();
        $("#creator-input").show();
        $("#creation-input").show();
        $("#creation-input").show();
        $("#last-changer-input").show();
        $("#last-changer-input").show();
        $("#last-change-input").show();
        $("#last-change-input").show();
        $("#meta-div").show();
        $("#creator-input").val(accessKey.creator);
        $("#creator-input").attr("readonly","true");
        const creation = accessKey.creation;
        if (creation === undefined) {
          $("#creation-input").val("");
        } else {
          $("#creation-input").val(new Date(creation).toLocaleString());
        }
        $("#creation-input").attr("readonly","true");
        $("#last-changer-input").val(accessKey.lastChanger);
        $("#last-changer-input").attr("readonly","true");
        const lastChange = accessKey.lastChange;
        if (lastChange === undefined) {
          $("#last-change-input").val("");
        } else {
          $("#last-change-input").val(new Date(lastChange).toLocaleString());
        }
        $("#last-change-input").attr("readonly","true");
        $("#add-btn").hide();
        $("#modal-alert-div").hide();
        $("#update-btn").show();
        $("#delete-btn").show();
      }
      if (data.mode == "new") {
        $("#id-div").hide();
        $("#value-div").show();
        $("#value-input").val("");
        $("#type-input").val("read");
        $("#comment-textarea").val("");
        $("#value-gen-btn").show();
        $("#add-btn").show();
        $("#delete-btn").hide();
        $("#update-btn").hide();
        $("#meta-div").hide();
        $("#modal-alert-div").hide();
        $("#value-input").removeClass("is-invalid");
      }
    };
    const handleDeleteButtonClicked = () => {
      $("#delete-btn").prop("disabled", true);
      $("#update-btn").prop("disabled", true);
      $(".modal-close-btn").prop("disabled", true);
      const accessKeyId = $("#id-input").val();
      this._client.deleteKey(accessKeyId, (error, data) => {
        if (!error) {
          const index = this._tableModel.data.findIndex(key => key.value === accessKeyId);
          if (index == -1) {
            console.error("inconsistency");
          } else {
            this._tableModel.deleteRow(index);
            $("#key-modal").modal("hide");
            $("#add-alert-div").hide();
            $("#success-alert-div").text(this._getI18n("mir.accesskey.delete.success")
              .format(accessKeyId.substring(0, 7)));
            $("#success-alert-div").show();
          }
        } else {
          this._handleModalError(error);
        }
      });
      $("#delete-btn").prop("disabled", false);
      $("#update-btn").prop("disabled", false);
      $(".modal-close-btn").prop("disabled", false);
    };
    const handleUpdateButtonClicked = () => {
      $("#delete-btn").prop("disabled", true);
      $("#update-btn").prop("disabled", true);
      $(".modal-close-btn").prop("disabled", true);
      const accessKey = {
        "type": $("#type-input").val(),
        "comment": $("#comment-textarea").val()
      };
      const accessKeyId = $("#id-input").val();
      this._client.updateKey(accessKeyId, accessKey, (error, data) => {
        $("#add-alert-div").hide();
        if (!error) {
          const index = this._tableModel.data.findIndex(key => key.value === accessKeyId);
          if (index == -1) {
            console.error("inconsistency");
          } else {
            if (data.creation === undefined) {
              this._tableModel.deleteRow(index);
              this._tableModel.addRow(data);
            } else {
              this._tableModel.updateRow(index, data);
            }
            $("#key-modal").modal("hide");
          }
          $("#success-alert-div").text(this._getI18n("mir.accesskey.update.success")
            .format(accessKeyId.substring(0, 7)));
          $("#success-alert-div").show();
        } else {
          this._handleModalError(error);
        }
      });
      $("#delete-btn").prop("disabled", false);
      $("#update-btn").prop("disabled", false);
      $(".modal-close-btn").prop("disabled", false);
    };
    const handleGeneratorButtonClicked = () => {
      $("#value-input").val(generateKey(32));
    };
    const handleAddButtonClicked = () => {
      $(".closeModal").prop("disabled", true);
      $("#add-btn").prop("disabled", true);
      const accessKey = {
        value: $("#value-input").val(),
        type: $("#type-input").val(),
        comment: $("#comment-textarea").val(),
      };
      if (!isValidValue(accessKey.value)) {
        $(".closeModal").prop("disabled", false);
        $("#add-btn").prop("disabled", false);
        $("#value-input").addClass("is-invalid");
        return;
      } else {
        $("#value-input").removeClass("is-invalid");
      }
      this._client.addKey(accessKey, (error, data) => {
        if (!error) {
          this._tableModel.addRow(data);
          $("#key-modal").modal("hide");
          $("#add-alert-id").text("(" + data.value.substring(0, 7) + ")");
          $("#add-alert-type").text(this._getI18n("mir.accesskey.type." + data.type));
          $("#add-alert-value").text(accessKey.value);
          $("#success-alert-div").hide();
          $("#add-alert-div").show();
        } else {
          this._handleModalError(error);
        }
      });
      $(".closeModal").prop("disabled", false);
      $("#add-btn").prop("disabled", false);
    };
    $("#add-btn").click(handleAddButtonClicked);
    $("#delete-btn").click(handleDeleteButtonClicked);
    $("#update-btn").click(handleUpdateButtonClicked);
    $("#value-gen-btn").click(handleGeneratorButtonClicked);
    $("#key-modal").on("show.bs.modal", handleShowEditModal);
    $("#type-popover").popover({
      html: true,
      content: this._getI18n("mir.accesskey.information.type"),
      container: $("#key-modal")
    });
    $("#value-popover").popover({
      html: true,
      content: this._getI18n("mir.accesskey.information.value"),
      container: $("#key-modal")
    });
    $("#alert-success-value").tooltip();
    $("#alert-success-value").click(function() {
      copyToClipboard($(this).text());
    });
  }
  _initPaginationHandler() {
    const handleItemLimitChanged = (itemLimit) => {
      const itemOffset = this._paginatorModel.itemOffset;
      this._updateTableModel(itemOffset, itemLimit);
    }
    const handlePaginatorClicked = event => {
      const target = $(event.currentTarget);
      if (!target.hasClass("disabled") && !target.hasClass("active")) {
        $("#add-alert-div").hide();
        $("#success-alert-div").hide();
        const id = target[0].id;
        if (id == "pre") {
          this._paginatorModel.pageOffset -= 1;
        } else if (id == "next") {
          this._paginatorModel.pageOffset += 1;
        } else {
          const offsetText = target.text();
          this._paginatorModel.pageOffset = parseInt(offsetText) - 1;
        }
        this._updateTableModel(this._paginatorModel.itemOffset, 
        this._paginatorModel.itemLimit);
      }
    }
    this._paginatorModel.on("itemLimitChanged", handleItemLimitChanged);
    $("ul.pagination").find("li").click(handlePaginatorClicked);
  }
  _handleModalError(error) {
    const errorString = this._handleError(error);
    $("#modal-alert-div").text(errorString);
    $("#modal-alert-div").show();
  }
  _handleError(error) {
    $("#add-alert-div").hide();
    $("#success-alert-div").hide();
    if (error.status < 500) {
      const result = error.responseJSON;
      if (result !== undefined) {
        if (result.errorCode !== undefined) {
          let errorMessage = this._getI18n("mcr.accesskey.error." + result.errorCode);
          if (errorMessage !== undefined) {
            return errorMessage;
          } else {
            return result.message;
          }
        } else {
          return result.message;
        }
      } 
    }
    return error.statusText;
  }
  _renderPagination() {
    const pageCount = this._paginatorModel.currentPageCount;
    const pageOffset = this._paginatorModel.pageOffset;
    const items = $("ul.pagination").find("li");
    items.show();
    items.removeClass("active");
    const middle = Math.floor(items.length / 2);
    if (pageCount > 0 && pageCount > items.length - 2) {
      items.eq(1).find("a").text(1);
      items.eq(items.length - 2).find("a").text(pageCount);
      if (pageOffset < middle - 1) {
        for (let index = 2; index < items.length - 3; index++) {
          items.eq(index).find("a").text(index);
        }
        items.eq(items.length - 3).find("a").text("..");
        items.eq(items.length - 3).addClass("disabled");
        items.eq(2).removeClass("disabled");
        items.eq(pageOffset + 1).addClass("active");
      } else if (pageOffset > pageCount - middle - 1) {
        let counter = 0;
        for (let index = items.length - 2; index > 2; index--) {
          items.eq(index).find("a").text(pageCount - counter);
          counter++;
        }
        items.eq(2).find("a").text("..");
        items.eq(2).addClass("disabled");
        items.eq(items.length - 3).removeClass("disabled");
        items.eq(items.length - (pageCount - pageOffset + 1)).addClass("active");
      } else {
        items.eq(2).find("a").text("..");
        items.eq(2).addClass("disabled");
        items.eq(items.length - 3).find("a").text("..");
        items.eq(items.length - 3).addClass("disabled");
        let current = Math.floor((pageOffset + 1) - ((items.length - 6 - 1) / 2));
        for (let index = 3; index < items.length - 3; index++) {
          items.eq(index).find("a").text(current);
          current++;
        }
        items.eq(middle).addClass("active");
      }
    } else {
      for (let index = 1; index < items.length - 1; index++) {
        if (index > pageCount) {
          items.eq(index).hide();
        } else {
          items.eq(index).find("a").text(index);
        }
      }
      items.eq(2).removeClass("disabled");
      items.eq(items.length - 3).removeClass("disabled");
      items.eq(pageOffset + 1).addClass("active");
    }
    if (pageCount == 1) {
      items.first().addClass("disabled");
      items.last().addClass("disabled");
    } else {
      if (pageOffset == 0) {
        items.first().addClass("disabled");
        items.last().removeClass("disabled");
      } else if (pageOffset == pageCount - 1) {
        items.first().removeClass("disabled");
        items.last().addClass("disabled");
      } else {
        items.first().removeClass("disabled");
        items.last().removeClass("disabled");
      }
    }
  }
  _renderRow(index, accessKey) {
    const row = $("#key-table").find("tbody").find("tr").eq(index);
    if (accessKey === undefined) {
      for (let jindex = 1; jindex < 3; jindex++) {
        row.find("td").eq(jindex).text("");
      }
      row.css("visibility", "hidden");
    } else {
      const indexCell = row.find("td").eq(0);
      indexCell.text(accessKey.value.substring(0,7));
      const typName = this._getI18n("mir.accesskey.type." + accessKey["type"]);
      const typeCell = row.find("td").eq(1);
      typeCell.text(typName);
      const comment = accessKey["comment"];
      const commentCell = row.find("td").eq(2);
      /*if (comment.length > 64) {
        commentCell.text(comment.substring(0, 61) + "...");
      } else {*/
        commentCell.text(comment);
      //}
      row.css("visibility", "visible");
    }
  }
  _renderTable(startIndex, data) {
    const tableRows = $("#key-table").find("tbody").find("tr");
    for (let index = 0; index < tableRows.length; index++) {
      if (index < data.length) {
        const accessKey = data[index];
        this._renderRow(index, accessKey);
      } else {
        this._renderRow(index);
      }
    }
  }
  _initTable(itemLimit) {
    const row = $("#key-table").find("tbody tr:first");
    $("#key-table tbody > tr").remove();
    for (let index = 0; index < itemLimit; index++) {
      let newRow = row.clone();
      $(newRow).find("td:last a").attr("data-index", index);
      $("#key-table tbody").append(newRow);
    }
  }
}
class Client {
 constructor(id, token) {
   this._id = id;
   this._token = token;
 }
 getKeys(offset, limit, callback) {
   const token = this._token;
   let queryString = "";
   if (offset !== undefined && limit !==undefined) {
     queryString = "?offset=" + offset + "&limit=" + limit;
   }
   $.ajax({
     url: API_URL + this._id + "/accesskeys"+ queryString,
     type: "GET",
     beforeSend: function (xhr) {
       if (token != undefined) {
         xhr.setRequestHeader("Authorization", token.token_type + " " + token.access_token);
       }
     },
     error: function (data) {
       return callback(data, null);
     },
     success: function (data) {
       return callback(null, data);
     },
   });
 }
 addKey(accessKey, callback) {
   const token = this._token;
   $.ajax({
     url: API_URL + this._id + "/accesskeys",
     type: "POST",
     data: JSON.stringify(accessKey),
     contentType: "application/json",
     success: function (data) {
       return callback(null, data);
     },
     beforeSend: function (xhr) {
       if (token != undefined) {
         xhr.setRequestHeader("Authorization", token.token_type + " " + token.access_token);
       }
     },
     error: function (data) {
       return callback(data, null);
     },
   });
 }
 deleteKey(value, callback) {
   const token = this._token;
   $.ajax({
     url: API_URL + this._id + "/accesskeys/" + value,
     type: "DELETE",
     beforeSend: function (xhr) {
       if (token != undefined) {
         xhr.setRequestHeader("Authorization", token.token_type + " " + token.access_token);
       }
     },
     error: function (data) {
       return callback(data, null);
     },
     success: function (data) {
       return callback(null, data);
     }
   });
 }
 updateKey(value, accessKey, callback) {
   const token = this._token;
   $.ajax({
     url: API_URL + this._id + "/accesskeys/" + value,
     type: "PUT",
     data: JSON.stringify(accessKey),
     contentType: "application/json",
     error: function (data) {
       return callback(data, null);
     },
     beforeSend: function (xhr) {
       if (token != undefined) {
         xhr.setRequestHeader("Authorization", token.token_type + " " + token.access_token);
       }
     },
     success: function (data) {
       return callback(null, data);
     }
   });
 }
}
$(document).ready(function () {
  const objectId = getParameterByName("objId");
  const url = getParameterByName("url");
  $("#back-btn").click(function() {
    if (url === undefined) {
      if (objectId !== undefined) {
        window.location = webApplicationBaseURL + "receive/" + objectId;
      } else {
        window.location = webApplicationBaseURL;
      }
    } else {
      window.location = url;
    }
  });
  if (objectId !== undefined) {
    $.ajax({
      url: webApplicationBaseURL + "rsc/jwt",
      type: "GET",
      data: {
        ua: "acckey_" + objectId
      },
      dataType: "json",
      success: function(data) {
        if (data.login_success) {
          const client = new Client(objectId, data);
          new MIRAccessKeyEditor(client);
        } else {
          $("#spinner").hide();
          $("#error-alert-div").show();
        }
      },
      error: function(data) {
        $("#spinner").hide();
        $("#error-alert-div").show();
      }
    });
  } else {
    $("#spinner").hide();
    $("#error-alert-div").show();
  }
});
