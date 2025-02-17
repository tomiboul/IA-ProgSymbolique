from fastapi import FastAPI, status, HTTPException, Request
from fastapi.staticfiles import StaticFiles
from fastapi.responses  import RedirectResponse
from fastapi.templating import Jinja2Templates

#import les router
from app.route.acceuil import router as routerAcceuil

app = FastAPI(title="Ia et programmation symbolique")
app.include_router(routerAcceuil)

app.mount("/static", StaticFiles(directory="././static"), name='static')
app.mount("/images", StaticFiles(directory="././images"), name='images')
templates = Jinja2Templates(directory="././templates")



@app.on_event('startup') 
def on_startup():
    print("Server started.")
    #delete_database()
    #create_database()


def on_shutdown():
    print("Bye bye!")


@app.get("/")
def root():
    return RedirectResponse("/NotreJeu/accueil", status_code=status.HTTP_303_SEE_OTHER)



@app.exception_handler(HTTPException)
def Exceptionhandler(request: Request, exc: HTTPException):
    return templates.TemplateResponse(
        "exceptions.html",
        context={
            "request": request,
            "status_code": exc.status_code,
            "message:" : exc.detail
        }
    )
