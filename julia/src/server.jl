using HTTP
include("webframework.jl")
using .WebFramework
using .WebFramework.Inputs

include("todo.jl")

function get_content_type(path::String)
    if endswith(path, ".css")
        return "text/css"
    elseif endswith(path, ".js")
        return "application/javascript"
    else
        return "text/plain"
    end
end

function handler(req::HTTP.Request)
    try
        path = req.target
        
        if startswith(path, "/public/")
            try
                file_path = "." * path
                content = read(file_path, String)
                return HTTP.Response(200, ["Content-Type" => get_content_type(path)], body=content)
            catch
                return HTTP.Response(404, "File not found")
            end
        end
        
        return handle_request(req)
    catch e
        if isa(e, IOError) && e.code == -32
            return HTTP.Response(200)
        else
            rethrow(e)
        end
    end
end

HTTP.serve(handler, "127.0.0.1", 8080)