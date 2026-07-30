# ==============================================================================
# WHAT: Web Fetcher Tool
# WHAT FOR: Giving the LLM the ability to read raw internet pages.
# WHY: Offline model needs external intel for current documentation, PoCs, or targets.
# HOW: Native urllib request, basic User-Agent spoofing to bypass lazy WAFs.
# ITERATION: 1.0 (Raw text extraction with hard limits)
# ==============================================================================

import urllib.request
from pydantic import BaseModel, Field

class Function(BaseModel):
    """
    Fetches the raw HTML/text content of a given URL from the internet.
    Useful for reading documentation, articles, or scraping target data.
    """

    # --------------------------------------------------------------------------
    # Wymagany parametr: URL do zaciągnięcia
    # --------------------------------------------------------------------------
    url: str = Field(
        ...,
        description="The full HTTP/HTTPS URL of the website to fetch.",
    )

    @classmethod
    def execute(cls, url: str) -> str:
        # ----------------------------------------------------------------------
        # Przebieramy się za zwykłą przeglądarkę, inaczej Cloudflare albo inne
        # gówno odrzuci nas z błędem 403 Forbidden.
        # ----------------------------------------------------------------------
        req = urllib.request.Request(
            url,
            headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        )

        try:
            with urllib.request.urlopen(req, timeout=10) as response:
                html = response.read().decode('utf-8', errors='ignore')
                
                # Zabezpieczenie: ucinamy do 15k znaków.
                # Większe gówno wyjebie Ci okno kontekstowe w modelu lokalnym
                # i Qwen dostanie schizofrenii.
                return html[:15000]
                
        except Exception as e:
            return f"Error fetching {url}: {str(e)}"

    @classmethod
    def openai_schema(cls):
        # ----------------------------------------------------------------------
        # Rejestracja Pydantic -> API format
        # ----------------------------------------------------------------------
        schema = cls.model_json_schema()
        return {
            "type": "function",
            "function": {
                "name": "fetch_webpage",
                "description": cls.__doc__.strip() if cls.__doc__ else "",
                "parameters": {
                    "type": "object",
                    "properties": schema.get("properties", {}),
                    "required": schema.get("required", []),
                },
            },
        }
