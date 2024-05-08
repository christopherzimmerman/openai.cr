module JsonSchema
    enum DataType
        Object
        Number
        Integer
        String
        Array
        Null
        Boolean
    end

    class Definition
        include JSON::Serializable

        @[JSON::Field(key: "type")]
        property type : DataType

        @[JSON::Field(key: "description")]
        property description : String? = nil

        @[JSON::Field(key: "properties")]
        property properties : Hash(String, Definition)? = nil

        @[JSON::Field(key: "required")]
        property required : Array(String)? = nil

        @[JSON::Field(key: "items")]
        property items : Definition? = nil

        @[JSON::Field(key: "enum")]
        property members : Array(String)? = nil

        def initialize(
            @type : DataType,
            @description : String? = nil,
            @properties : Hash(String, Definition)? = nil,
            @required : Array(String)? = nil,
            @items : Definition? = nil,
            @members : Array(String)? = nil,
        )
        end
    end
end