from groq import Groq
import sys
import os

client = Groq()

file_simulation_diff = "./terraform/simulation_pr.diff"

try:
    with open(file_simulation_diff, "r", encoding="utf-8") as file :
        git_diff = file.read()
    
except FileNotFoundError:
    print(f" Arquivo não encontrado: {FileNotFoundError}")
    sys.exit(1)

prompt_ia = """

    Sua tarefa é revisar o `git diff` de um Pull Request contendo alterações em arquivos Terraform.

    Analise as mudanças e responda focando em 3 pilares:
    1. Segurança (Portas abertas, segredos expostos, criptografia).
    2. Custos (Superdimensionamento de instâncias, tipos de discos caros).
    3. Boas Práticas (Uso de variáveis para dados sensíveis).

    Como o usuário enviou um diff onde o código foi CORRIGIDO (as linhas ruins com '-' foram removidas e as boas com '+' foram adicionadas):
    - Valide as correções feitas, confirmando se os problemas de segurança e custo foram mitigados com sucesso.
    - Seja direto, técnico e pragmático. Use formatação Markdown para a resposta.
    """

print("Enviando o diff para a IA analisar...")

try:
    response = client.chat.completions.create(
        
        model="llama3-70b-8192",
        messages=[
            {"role":"system", "content": prompt_ia},
            {"role": "user", "content": f"Analise as correções deste git diff:\n\n{git_diff}"}
        ],
        temperature=0.2
    )
        
    print(f"Resultado: {response.choices[0].message.content}")
        
except Exception as e:
    print(f"Erro: {e}")