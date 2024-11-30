module WebFramework

using HTTP
include("inputs.jl")
using .Inputs

export render, response
export h1, h2, h3, h4, h5, h6, p, div, span
export a, img, button, input, form, label
export ul, ol, li, table, tr, td, th
export header, footer, nav, main, section, article
export aside, figure, figcaption, blockquote
export pre, code, br, hr, strong, em, form

function element(tag::String, content=""; kwargs...)
    attrs = Dict{Symbol,String}()
    for (k,v) in kwargs
        if k == :for_id
            attrs[:for] = string(v)
        else
            attrs[k] = string(v)
        end
    end
    
    attributes = isempty(attrs) ? "" : " " * join(["$k=\"$(attrs[k])\"" for k in keys(attrs)], " ")
    
    if isempty(content)
        "<$tag$attributes />"
    else
        "<$tag$attributes>$content</$tag>"
    end
end

for tag in [:h1, :h2, :h3, :h4, :h5, :h6, :p, :div, :span,
            :a, :button, :label, :pre, :code, :strong, :em,
            :header, :footer, :nav, :main, :section, :article,
            :aside, :figure, :figcaption, :blockquote,
            :ul, :ol, :li, :table, :tr, :td, :th, :form]
    @eval begin
        function $tag(content=""; kwargs...)
            element($(string(tag)), content; kwargs...)
        end
    end
end

for tag in [:img, :input, :br, :hr]
    @eval begin
        function $tag(; kwargs...)
            element($(string(tag)), ""; kwargs...)
        end
    end
end

function read_template(template_path::String)
    open(template_path) do file
        read(file, String)
    end
end

function render(content; title="Web App", template_path="templates/index.html")
    template = read_template(template_path)
    rendered = replace(template, "{{title}}" => title)
    rendered = replace(rendered, "{{content}}" => content)
    return rendered
end

function response(content)
    HTTP.Response(200, render(content))
end

end
