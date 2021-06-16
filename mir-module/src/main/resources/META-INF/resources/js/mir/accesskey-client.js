const RSC_URL = webApplicationBaseURL + "rsc/accesskeys/";
class Client {
    constructor(id) {
        this._id = id;
    }
    getKeys(offset, limit, callback) {
        $.ajax({
            url: RSC_URL + this._id + "?offset=" + offset + "&limit=" + limit,
            type: "GET",
            error: function (data) {
                return callback(data, null);
            },
            success: function (data) {
                return callback(null, data);
            },
        });
    }
    addKey(accessKey, callback) {
        $.ajax({
            url: RSC_URL + this._id,
            type: "POST",
            data: JSON.stringify(accessKey),
            contentType: "application/json",
            success: function (data) {
                return callback(null, data);
            },
            error: function (data) {
                return callback(data, null);
            },
        });
    }
    deleteKey(value, callback) {
        $.ajax({
            url: RSC_URL + this._id + "/" + value,
            type: "DELETE",
            error: function (data) {
                return callback(data, null);
            },
            success: function (data) {
                return callback(null, data);
            }
        });
    }
    updateKey(id, accessKey, callback) {
        $.ajax({
            url: RSC_URL + this._id + "/" + id,
            type: "PUT",
            data: JSON.stringify(accessKey),
            contentType: "application/json",
            error: function (data) {
                return callback(data, null);
            },
            success: function (data) {
                return callback(null, data);
            }
        });
    }
}
