# PRD — Migração dos dotfiles para Hyprland (rice grayscale)

> **Status:** rascunho para revisão
> **Data:** 2026-07-18
> **Repo alvo:** `~/config` (dotfiles Arch Linux + Ansible)

## Decisões tomadas (perguntas resolvidas em 2026-07-18)

1. **Login:** `greetd` + `tuigreet` — tela de login em texto minimalista, leve, na estética do rice. Vira requisito (RF-19).
2. **Rede/Bluetooth:** o cenário é instalação limpa do Arch — o playbook **verifica e instala** NetworkManager e BlueZ se faltarem, e habilita os serviços. Vira requisito (RF-20).
3. **GPU:** não é NVIDIA — nenhum tratamento especial; permanece fora de escopo.

---

## 1. Contexto e Visão Geral (O Porquê)

**Problema.** O repo hoje serve dois donos ao mesmo tempo: um desktop de desenvolvimento (GNOME/XFCE) e uma TV box (perfil `server` com OpenSSH, Podman, Kodi/RetroArch). A TV box não é mais mantida por este repo, então o perfil `server`, o prompt interativo de perfil e as roles associadas são peso morto. Além disso:

- O theming e o Rofi carregam lógica de detecção de DE (gsettings/xfconf) e um workaround de XWayland que só existem por causa do GNOME/Mutter.
- O `script.sh` (535 linhas) duplica o playbook Ansible e já está divergente dele.
- O `AGENT.md` descreve um setup que não existe mais (Fedora, Homebrew, Contour, neofetch).
- O editor oficial é VS Code, mas o fluxo de trabalho migrou para Neovim/LazyVim.

**Situação atual.** Playbook Ansible funcional e idempotente para GNOME/XFCE, com dois perfis de instalação, VS Code como editor e visual sem identidade única.

**Objetivo.** Transformar o repo na fonte de verdade de **uma única máquina**: um desktop Arch rodando **Hyprland riced em paleta grayscale** — animações fluidas, blur, cantos arredondados, launcher Spotlight-style e um **control center lateral estilo celular** — com **LazyVim** como editor, tudo instalado e versionado pelo mesmo `ansible-playbook site.yml` de sempre.

**Fora de escopo.**
- Suporte a GNOME, XFCE ou qualquer outro DE/WM (o histórico fica no git).
- Manutenção da TV box / perfil server.
- Theming do display manager (SDDM/GDM).
- Suporte a outra distro que não Arch Linux.

## 2. Personas e Histórias de Usuário (Para Quem)

**Persona única:** Davi — dev que usa Arch como daily driver, versiona o ambiente em Ansible e quer um desktop bonito sem abrir mão de reprodutibilidade (formatou → clonou → rodou o playbook → está em casa).

Histórias:

- Como **dono do ambiente**, quero **rodar `ansible-playbook site.yml` numa instalação limpa do Arch**, para **sair com o desktop Hyprland completo e riced sem passos manuais**.
- Como **dono do ambiente**, quero **um tema grayscale consistente entre Hyprland, Waybar, Rofi, swaync e Ghostty**, para **que o desktop pareça um sistema só, não uma colagem**.
- Como **usuário diário**, quero **abrir um control center lateral (estilo celular) com toggles de wifi, bluetooth, volume e DND**, para **ajustar o sistema sem abrir um app de configurações**.
- Como **usuário diário**, quero **abrir o launcher com `Super+Space` nativamente no Wayland**, para **não depender de workarounds de XWayland**.
- Como **dev**, quero **que o `nvim` já venha com a minha config LazyVim clonada do GitHub**, para **editar código imediatamente após o setup, sem VS Code**.
- Como **mantenedor do repo**, quero **remover o perfil server, o script.sh e a lógica multi-DE**, para **ter um único caminho de instalação para manter**.

## 3. Requisitos Funcionais (O Quê) — MoSCoW

### Must have

- **RF-01 — Role `hyprland`:** instala `hyprland`, `xdg-desktop-portal-hyprland`, `waybar`, `swww`, `cliphist`, `grim` + `slurp`, `wl-clipboard`, e polkit agent. Configs versionadas em `base_config/hypr/` e symlinkadas pela role `dotfiles`.
- **RF-02 — Rice grayscale do Hyprland:** `hyprland.conf` com paleta monocromática (bordas, gaps, cantos arredondados, blur, sombras) e curvas bezier customizadas para animações fluidas de janela/workspace.
- **RF-03 — Waybar grayscale:** barra com workspaces, relógio, tray, rede, áudio e bateria (se houver), estilizada em CSS na mesma paleta.
- **RF-04 — Control center lateral (swaync):** `swaync` configurado como painel que desliza da lateral, estilo celular, com notificações + toggles (wifi, bluetooth, DND, volume/brilho via sliders), CSS grayscale. Bind dedicado no `hyprland.conf` (ex.: `Super+N`).
- **RF-05 — Rofi mantido, nativo Wayland:** o launcher continua sendo o Rofi com tema Spotlight-style (adaptado para grayscale) e atalho `Super+Space`. Trocar o pacote `rofi` por `rofi-wayland`, remover o hack `env -u WAYLAND_DISPLAY ... -normal-window` e o binding via gsettings/xfconf — o Hyprland não tem launcher nem atalhos de fábrica, então `Super+Space` vira `bind = SUPER, SPACE, exec, rofi -show drun` no `hyprland.conf`.
- **RF-06 — Role `neovim` (LazyVim):** instala `neovim`, `ripgrep`, `fd`, `lazygit` e clona `https://github.com/davieduardo001/lazyvim-config` em `~/.config/nvim` (se o diretório já existir e não for um clone desse repo, não sobrescrever — avisar).
- **RF-07 — Remover VS Code:** tirar `visual-studio-code-bin` de `aur_packages` e de toda a documentação (as únicas referências hoje estão em `all.yml` e no `script.sh`, que também sai).
- **RF-08 — Remover perfil server:** apagar roles `ssh` e `podman`, `flatpak_apps_server` (Kodi/RetroArch), o `vars_prompt` de perfil e toda a lógica `install_profile` do `site.yml`.
- **RF-09 — Remover `script.sh`:** o Ansible passa a ser o único caminho de instalação.
- **RF-10 — Remover lógica GNOME/XFCE:** roles `theming` e `rofi` deixam de detectar DE; ícones/cursor passam a ser aplicados via `gsettings` (GTK apps sob Hyprland) + arquivos GTK versionados, sem ramos xfconf.
- **RF-11 — Documentação:** README reescrito para o novo stack; `AGENT.md` reescrito ou removido.
- **RF-19 — Login via greetd + tuigreet:** instala `greetd` e `greetd-tuigreet`, configura o tuigreet para listar/iniciar a sessão Hyprland e habilita o serviço `greetd` (desabilitando display manager anterior, se houver).
- **RF-20 — Rede e Bluetooth garantidos:** instala `networkmanager`, `bluez` e `bluez-utils` caso faltem, e habilita `NetworkManager.service` e `bluetooth.service` — pré-requisito dos toggles de wifi/bluetooth do swaync numa instalação limpa.
- **RF-21 — Apps desktop** _(adicionado em 2026-07-18, pós-aprovação; revisado no mesmo dia)_: OnlyOffice (visualização/edição leve de docs), GNOME Calculator, Syncthing (com `syncthing@user.service` habilitado e iniciado), LocalSend, Firefox e Chromium. Brave removido do setup (entra em `packages_absent`).

### Should have

- **RF-12 — Lock/idle:** `hyprlock` (tela de bloqueio grayscale) + `hypridle` (timeout → lock → dpms off).
- **RF-13 — Wallpaper com transição:** `swww` com script de troca de wallpaper (usando `wallpapers/`) e transição animada.
- **RF-14 — Screenshots com bind:** `grim`+`slurp`+`satty` amarrados a binds — `Super+Shift+S` recorte com anotação via satty (estilo Win+Shift+S do Windows), `Print` região direto pro clipboard, `Shift+Print` tela cheia → arquivo.
- **RF-15 — Clipboard history:** `cliphist` com bind abrindo histórico via rofi.

### Could have

- **RF-16 — wlogout** (menu de logout/power) no mesmo tema grayscale.
- **RF-17 — Window rules** por app (opacidade/floating para pickers, pavucontrol etc.).
- **RF-18 — GTK dark grayscale** forçado via `gsettings` para apps GTK.

### Won't have (desta vez)

- Multi-DE / multi-perfil / multi-distro.
- Theming de display manager (tuigreet fica com o visual padrão em texto).
- Suporte NVIDIA específico (confirmado: a GPU não é NVIDIA).
- Migração ou desativação remota da TV box existente.
- Obsidian — nunca esteve no repo; entra só se for pedido explicitamente.

## 4. Requisitos Não-Funcionais

- **Idempotência:** re-rodar o playbook não pode reinstalar nem re-clonar nada desnecessariamente (`--needed`, `creates:`, symlinks com `state: link`); segundo run em máquina já configurada termina com `changed=0` nas tasks de config.
- **Reprodutibilidade:** instalação limpa do Arch → playbook → desktop funcional, sem passo manual além do bootstrap `git`/`ansible` e senhas interativas já documentadas.
- **Performance:** animações fluidas (60 fps+) no hardware atual; blur e sombras configurados sem degradar uso de GPU perceptivelmente.
- **Manutenibilidade:** paleta grayscale definida uma vez (arquivo de cores único em `base_config/`, ex. `colors.conf`/variáveis CSS) e referenciada por Hyprland/Waybar/swaync/Rofi — trocar a paleta no futuro deve ser mudança em um lugar só.
- **Segurança:** nenhuma credencial no repo; a remoção do sshd deste playbook não afeta máquinas que não são geridas por ele.

## 5. Métricas de Sucesso (KPIs)

_(repo pessoal — métricas de verificação, não de negócio)_

- Playbook completo em instalação limpa termina com `failed=0` em 1 execução.
- Segundo run consecutivo: `changed=0` nas tasks de configuração/dotfiles.
- Zero ocorrências de `xfconf`, `install_profile`, `visual-studio-code`, `script.sh` no repo após a migração (`git grep` limpo, fora de `docs/`).
- Tempo de "formatei → desktop pronto" ≤ 1h em conexão normal (_suposição de baseline, validar na primeira instalação real_).

## 6. UX/UI & Fluxo do Usuário

Sem Figma — a referência visual é textual:

- **Paleta:** fundo `#0a0a0a`–`#121212`, superfícies `#1a1a1a`–`#242424`, bordas/realce `#3a3a3a`–`#5a5a5a`, texto `#d4d4d4`–`#eeeeee`. Nenhum matiz colorido; hierarquia só por luminância. Acento opcional: branco puro.
- **Fluxo do control center:** `Super+N` (ou clique no ícone da Waybar) → painel desliza da **lateral direita** com animação de slide (estilo notification shade de celular) → topo com toggles em grade (wifi, bluetooth, DND), sliders de volume/brilho → lista de notificações abaixo → `Esc`/mesmo bind fecha deslizando de volta.
- **Fluxo do launcher:** `Super+Space` → Rofi centralizado estilo Spotlight, campo de busca grande, lista limpa, sem ícones coloridos chamativos.
- **Janelas:** gaps moderados, cantos arredondados (~10px), borda 2px que clareia na janela focada, blur discreto em superfícies translúcidas, animação de abertura tipo "pop-in" suave.

## 7. Informações Adicionais

- Config LazyVim de origem: `https://github.com/davieduardo001/lazyvim-config`.
- Mudança pendente não commitada no repo (fonte do Ghostty → JetBrainsMono) é intencional e deve ser preservada/commitada junto.
- O tema atual do Ghostty ("Min Dark") já é compatível com a paleta — manter.
- Pacotes previstos (consolidar na SPEC): `hyprland`, `xdg-desktop-portal-hyprland`, `waybar`, `swaync`, `rofi-wayland`, `swww`, `hyprlock`, `hypridle`, `cliphist`, `grim`, `slurp`, `wl-clipboard`, `polkit-gnome` (ou `hyprpolkitagent`), `greetd`, `greetd-tuigreet`, `networkmanager`, `bluez`, `bluez-utils`, `neovim`, `ripgrep`, `fd`, `lazygit`, `brightnessctl`, `pavucontrol`.
- `rofi-wayland` **conflita** com o pacote `rofi` — a migração precisa tratar a substituição.
- Dependência: skill `gerar-spec-tecnica` consome este PRD para gerar a SPEC de implementação.

## 9. Critérios de Aceite

1. `ansible-playbook site.yml --ask-become-pass` roda **sem prompt de perfil** e termina com `failed=0` em Arch limpo; segundo run termina com `changed=0` nas tasks de config.
2. Após reboot, o boot cai no **tuigreet**; login inicia a sessão Hyprland com Waybar visível, wallpaper aplicado via swww e tema grayscale (nenhum elemento com cor saturada em bar, launcher, control center ou bordas). `NetworkManager.service` e `bluetooth.service` estão `enabled` e `active`.
3. `Super+Space` abre o Rofi **nativo Wayland** (sem `WAYLAND_DISPLAY` unset, sem `-normal-window`) com tema Spotlight grayscale.
4. Bind dedicado abre o swaync **deslizando da lateral** com toggles funcionais de wifi, bluetooth e DND, e fecha com o mesmo bind/`Esc`.
5. `nvim` abre com a config LazyVim clonada de `davieduardo001/lazyvim-config`; `pacman -Q visual-studio-code-bin` retorna "not found".
6. `git grep -lE 'xfconf|install_profile|script\.sh'` não retorna nenhum arquivo (fora de `docs/`).
7. README e AGENT.md descrevem apenas o stack novo (Hyprland/LazyVim), sem menção a VS Code, perfil server, GNOME/XFCE, Fedora ou Homebrew.

## 10. Cenários de Teste

| # | Cenário | Resultado Esperado |
|---|---|---|
| **Instalação limpa** | | |
| 1 | Rodar o playbook em Arch recém-instalado | Termina `failed=0`, sem prompt de perfil |
| 2 | Reboot após o playbook | Boot cai no tuigreet; login entra na sessão Hyprland |
| 3 | Logar na sessão Hyprland | Waybar, wallpaper e binds funcionando; tema grayscale |
| 4 | Arch limpo sem NetworkManager/BlueZ | Playbook instala e habilita os dois; wifi e bluetooth operantes |
| 5 | Rodar o playbook uma segunda vez | `changed=0` nas tasks de config/dotfiles |
| **Launcher e binds** | | |
| 6 | Pressionar `Super+Space` | Rofi abre nativo Wayland, tema Spotlight grayscale |
| 7 | Pressionar bind do control center | swaync desliza da lateral; toggles wifi/bt/DND respondem |
| 8 | Pressionar `Print` (região) | Screenshot da seleção vai para o clipboard |
| **Editor** | | |
| 9 | Abrir `nvim` pela primeira vez | LazyVim carrega a config do repo pessoal; plugins instalam |
| 10 | Rodar o playbook com `~/.config/nvim` já existente (clone correto) | Task idempotente, não re-clona nem sobrescreve |
| 11 | Rodar o playbook com `~/.config/nvim` existente que **não** é o clone | Playbook avisa e não destrói o diretório |
| **Remoções** | | |
| 12 | Procurar `visual-studio-code-bin` em `all.yml` e no sistema | Ausente da lista; pacote não instalado |
| 13 | Procurar roles `ssh`/`podman` e `script.sh` no repo | Não existem mais |
| 14 | Máquina que tinha `rofi` (não-wayland) instalado | Playbook substitui por `rofi-wayland` sem conflito de pacote |

## 11. Testes de Regressão

| # | Funcionalidade existente | Deve continuar funcionando |
|---|---|---|
| 1 | Symlinks de dotfiles (bashrc, fastfetch, ghostty, rofi) | Role `dotfiles` cria/mantém todos os links, agora incluindo hypr/waybar/swaync |
| 2 | Ghostty com tema Min Dark e fonte JetBrainsMono | Config preservada e symlinkada |
| 3 | Runtimes: Node (fnm, trocou o NVM), pyenv, Rust | Bun removido em 2026-07-18 (redundante com Node) |
| 4 | Oh-My-Bash + Starship no shell | Prompt e plugins intactos |
| 5 | Fontes Nerd (CaskaydiaCove, JetBrainsMono) | Instaladas e detectadas pelo fontconfig |
| 6 | paru + pacotes AUR restantes (ghostty, onlyoffice, localsend) | Instalação `--needed` idempotente |
| 7 | Flatpak | Infra + remote Flathub instalados; Zen removido em 2026-07-18 (browsers agora são Firefox/Chromium nativos) |
| 8 | Ícones + cursor macOS | Papirus-Dark (trocou o McMojave em 2026-07-18) + apple_cursor, aplicados via gsettings sob Hyprland |
| 9 | Tags do playbook (`--tags dotfiles`, `--tags theming` etc.) | Continuam filtrando as roles corretas |
| 10 | Roles `github_cli` e `claude` | Checks/instalação inalterados |

---

> **Próximo passo:** revisar este PRD (especialmente as 3 perguntas em aberto) antes de aprovar. Com o PRD aprovado, gerar a SPEC técnica com a skill `gerar-spec-tecnica` e só então tocar no playbook.
