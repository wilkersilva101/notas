# Regras de Negócio - PostsController

## Checklist de Regras vs Testes

### 1. Autenticação
| Regra | Status | Teste |
|-------|--------|-------|
| Usuário deve estar logado para acessar qualquer ação | ✅ | `use_before_action(:authenticate_user!)` |

### 2. Autorização (CanCanCan)
| Regra | Status | Teste |
|-------|--------|-------|
| Usuário só pode gerenciar seus próprios posts | ✅ | `authorization` context - redireciona para root |
| Admin pode gerenciar posts de qualquer usuário | ✅ | Testes de update/destroy com admin e post de outro |
| Usuário não pode editar post de outro | ✅ | `redirects to root_path` |
| Usuário não pode deletar post de outro | ✅ | `does not change Post.count` |
| Dados não são alterados quando acesso negado | ✅ | `titulo` permanece igual após tentativa |

### 3. CRUD - Create
| Regra | Status | Teste |
|-------|--------|-------|
| Post é criado com usuário logado como dono | ✅ | `change(Post, :count).by(1)` |
| Parâmetros válidos: redirect para show + flash | ✅ | `redirect_to(post_path)` + flash notice |
| Parâmetros inválidos: re-render new + 422 | ✅ | `render_template(:new)` + `:unprocessable_content` |
| Associa `current_user` ao post | ✅ | Implícito - teste de criação com user logado |

### 4. CRUD - Read
| Regra | Status | Teste |
|-------|--------|-------|
| Index lista posts (ransack + paginação) | ✅ | `assigns(:posts)` + render template |
| Show exibe post específico | ✅ | `assigns(:post)` + render template |

### 5. CRUD - Update
| Regra | Status | Teste |
|-------|--------|-------|
| Atualiza dados do post | ✅ | Flash "atualizada" + redirect |
| Admin altera post de outro: cria notificação | ✅ | `change(Notification, :count).by(1)` |
| Admin recebe mensagem correta na notificação | ✅ | `include('Admin alterou o seu post')` |

### 6. CRUD - Destroy
| Regra | Status | Teste |
|-------|--------|-------|
| Deleta post do usuário | ✅ | `change(Post, :count).by(-1)` |
| Admin deleta post de outro: cria notificação | ✅ | `change(Notification, :count).by(1)` |
| Admin recebe mensagem correta na notificação | ✅ | `include('Admin excluiu o seu post')` |
| Redirect para index após delete | ✅ | `redirect_to(posts_path)` |

### 7. Permissões de Parâmetros (Strong Parameters)
| Regra | Status | Teste |
|-------|--------|-------|
| Apenas `titulo` e `descricao` são permitidos | ⚠️ | Implícito - testes usam apenas esses campos |

### 8. Integrações
| Regra | Status | Teste |
|-------|--------|-------|
| Ransack funciona na listagem | ✅ | `assigns(:posts)` retorna relation |
| Kaminari pagina resultados | ✅ | Teste implícito no index |
| CanCanCan bloqueia acesso não autorizado | ✅ | Testes de autorização |
| Rolify identifica admin corretamente | ✅ | Tests com `create(:user, :admin)` |

---

## Legenda
- ✅ **Coberto** - Tem teste específico validando a regra
- ⚠️ **Parcial** - Coberto indiretamente ou precisa de teste explícito
- ❌ **Não coberto** - Regra existe mas não tem teste

## Como adicionar novas regras

1. **Identifique a regra** no controller
2. **Crie um teste** que falhe se a regra for quebrada
3. **Adicione** à lista acima

### Exemplo: Nova regra "Post deve ter pelo menos 10 caracteres"

```ruby
# No spec
context 'validações adicionais' do
  it 'não cria post com descrição muito curta' do
    invalid_params = { post: { titulo: 'A', descricao: 'B' } }
    post :create, params: invalid_params
    expect(response).to have_http_status(:unprocessable_content)
  end
end
```

---

## Comando para verificar cobertura

```bash
# Ver cobertura dos testes
bundle exec rspec spec/controllers/posts_controller_spec.rb

# Ver relatório HTML completo
xdg-open coverage/index.html
```
