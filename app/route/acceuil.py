from uuid import uuid4
from typing import Annotated

from fastapi import APIRouter, HTTPException, status, Request, Form, Depends
from fastapi.responses import HTMLResponse
from fastapi.responses import RedirectResponse
from fastapi.templating import Jinja2Templates
from pydantic import ValidationError


router = APIRouter(prefix="/NotreJeu", tags=["NotreJeu"])
templates = Jinja2Templates(directory="./templates")


@router.get('/accueil')
def home(request : Request):  #, user:UserSchema = Depends(login_manager.optional)
    return templates.TemplateResponse('accueil.html', context={'request':request})
