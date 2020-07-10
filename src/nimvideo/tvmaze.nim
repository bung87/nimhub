# http://www.tvmaze.com/api
import ./najax


# var cont = proc (httpStatus: int; response: cstring) = 
#     console.log httpStatus,JSON.parse response
#   ajax(cstring"get",cstring"http://api.tvmaze.com/shows/1",cont = cont)