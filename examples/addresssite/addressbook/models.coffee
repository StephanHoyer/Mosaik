
module.exports.address =
    prototype : models.prototype
    fields : 
        firstname: 
            type: String
        lastname: 
            type: String
    methods :
        getFullname : () => this.firstname + this.lastname
