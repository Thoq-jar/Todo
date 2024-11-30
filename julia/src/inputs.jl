module Inputs

using HTTP

export input_text, input_email, input_password, input_number
export input_date, input_time, input_datetime
export input_checkbox, input_radio, input_file
export textarea, select, option
export parse_form_data

function parse_form_data(body::Vector{UInt8})
    parse_form_data(String(body))
end

function parse_form_data(body::String)
    result = Dict{String,String}()
    if isempty(body)
        return result
    end
    
    pairs = split(body, "&")
    for pair in pairs
        key, value = split(pair, "=")
        result[HTTP.unescapeuri(key)] = HTTP.unescapeuri(value)
    end
    return result
end

function base_input(type::String; attrs...)
    attributes = [:type => type]
    for (k, v) in attrs
        push!(attributes, k => v)
    end
    attrs_str = join([" $k=\"$v\"" for (k,v) in attributes])
    "<input$attrs_str />"
end

input_text(;attrs...) = base_input("text"; attrs...)
input_email(;attrs...) = base_input("email"; attrs...)
input_password(;attrs...) = base_input("password"; attrs...)
input_number(;attrs...) = base_input("number"; attrs...)

input_date(;attrs...) = base_input("date"; attrs...)
input_time(;attrs...) = base_input("time"; attrs...)
input_datetime(;attrs...) = base_input("datetime-local"; attrs...)

input_checkbox(;attrs...) = base_input("checkbox"; attrs...)
input_radio(;attrs...) = base_input("radio"; attrs...)
input_file(;attrs...) = base_input("file"; attrs...)

function textarea(content=""; attrs...)
    attrs_str = join([" $k=\"$v\"" for (k,v) in attrs])
    "<textarea$attrs_str>$content</textarea>"
end

function select(content=""; attrs...)
    attrs_str = join([" $k=\"$v\"" for (k,v) in attrs])
    "<select$attrs_str>$content</select>"
end

function option(content=""; attrs...)
    attrs_str = join([" $k=\"$v\"" for (k,v) in attrs])
    "<option$attrs_str>$content</option>"
end

end 