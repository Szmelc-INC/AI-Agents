# ==============================================================================
# WHAT: Reliable Web Search Tool (DDGS API)
# WHAT FOR: Giving the LLM the ability to search the internet without rate-limits.
# WHY: Public SearxNG/Google instances block bots. DDGS hits internal APIs.
# HOW: Uses the 'duckduckgo-search' package for stealthy, reliable JSON intel.
# ==============================================================================

from pydantic import BaseModel, Field
from ddgs import DDGS

class Function(BaseModel):
    """
    Searches the internet for current information, facts, or news. 
    Returns top results with titles, URLs, and text snippets.
    Use this to find current intel before executing other tasks.
    """

    query: str = Field(
        ...,
        description="The search query to look up on the internet.",
    )

    @classmethod
    def execute(cls, query: str) -> str:
        try:
            # Walimy prosto w wewnętrzne API bez limitów
            results = DDGS().text(query, max_results=5)
            
            if not results:
                return "Zero wyników. Spróbuj innego zapytania."
            
            output = []
            for i, res in enumerate(results):
                title = res.get('title', 'Brak tytułu')
                link = res.get('href', 'Brak URL')
                body = res.get('body', 'Brak opisu')
                output.append(f"{i+1}. {title}\nURL: {link}\nSnippet: {body}")
                
            return "\n\n".join(output)

        except Exception as e:
            return f"Błąd wyszukiwania: {str(e)}"

    @classmethod
    def openai_schema(cls):
        schema = cls.model_json_schema()
        return {
            "type": "function",
            "function": {
                "name": "internet_search",
                "description": cls.__doc__.strip() if cls.__doc__ else "",
                "parameters": {
                    "type": "object",
                    "properties": schema.get("properties", {}),
                    "required": schema.get("required", []),
                },
            },
        }
