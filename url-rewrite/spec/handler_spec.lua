-- Mock ngx
local ngx =  {
    log = spy.new(function() end),
    var = {
        upstream_uri = "mock"
    },
    ctx = {
      router_matches = {
        uri_captures = {}
      }
    }
}

_G.ngx = ngx

local URLRewriter = require('../handler')

describe("TestHandler", function()

  it("should test handler constructor", function()
    URLRewriter:new()
    assert.equal('url-rewriter', URLRewriter._name)
  end)

  it("should test rewrite of upstream_uri", function()
    URLRewriter:new()
    assert.equal('mock', ngx.var.upstream_uri)
    config = {
        url = "new_url"
    }
    URLRewriter:access(config)
    assert.equal('new_url', ngx.var.upstream_uri)
  end)

  it("should test rewrite of upstream_uri with params", function()
    URLRewriter:new()
    ngx.ctx.router_matches.uri_captures["code_parameter"] = "123456"
    config = {
        url = "new_url/<code_parameter>"
    }
    URLRewriter:access(config)
    assert.equal('new_url/123456', ngx.var.upstream_uri)
  end)

  it("should replace url params", function()
    URLRewriter:new()
    local mockUrl = "url/<param1>/<param2>"
    local iter = getRequestUrlParams(mockUrl)
    ngx.ctx.router_matches.uri_captures["param1"] = 123456
    ngx.ctx.router_matches.uri_captures["param2"] = "test"

    local result = resolveUrlParams(iter, mockUrl)

    assert.equal("url/123456/test", result)
  end)
end)
