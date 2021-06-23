const RSC_URL = webApplicationBaseURL + "api/v2/accesskeys/";
class Client {
    constructor(id, token) {
        console.log(token);
        this._id = id;
        this._token = token;
    }

    getKeys(offset, limit, callback) {
        const token = this._token;
        $.ajax({
            url: RSC_URL + this._id + "?offset=" + offset + "&limit=" + limit,
            type: "GET",
            beforeSend: function (xhr) {
                if (token != undefined) {
                    xhr.setRequestHeader("Authorization", token.token_type + " " + token.access_token);
                } else {
                    console.log(token);
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
            url: RSC_URL + this._id,
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
            url: RSC_URL + this._id + "/" + value,
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
    updateKey(id, accessKey, callback) {
        const token = this._token;
        $.ajax({
            url: RSC_URL + this._id + "/" + id,
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
