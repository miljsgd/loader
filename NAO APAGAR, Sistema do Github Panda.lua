-- RANDOM HUB | LOADER UNIVERSAL LEVE | GITHUB + PANDAAUTH
-- Detecta o jogo e baixa APENAS seu script, sem incorporar os outros scripts.
-- Os scripts ficam separados no PandaAuth Vault (vss), e este loader leve pode ficar no GitHub.
-- O carregamento executa somente a URL do jogo detectado.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- CONFIGURACAO DOS 4 LOADERS EXTERNOS
local Routes = {
    {
        Name = "CloverFall",
        UniverseId = 10765799968,
        PlaceId = 76894257773137,
        Url = "https://vault.pandauth.com/vss/966cd08a94107ba3", -- CLOVERFALL v1.05
    },
    {
        Name = "Black Grimoire",
        UniverseId = 1522593851,
        PlaceId = 4632627223,
        Url = "https://vault.pandauth.com/vss/e969613d84b680a5", -- BLACK GRIMOIRE v1.2
    },
    {
        Name = "Anime Piece",
        PlaceId = 134039915751463,
        Url = "https://vault.pandauth.com/vss/eb94fb065b4c4026", -- ANIME PIECE v1.3
    },
    {
        Name = "Anime Dimensions Simulator",
        UniverseId = 2655311011, -- GLOBAL: lobby e todos os lugares da mesma experiencia
        PlaceId = 6938803436,
        Url = "https://vault.pandauth.com/vss/fb1a157584775706", -- ANIME DIMENSIONS v1.01
    },
}

-- Defina true caso queira expulsar de jogos nao suportados, como no Universal antigo.
local KickUnsupported = true

local placeId = tonumber(game.PlaceId)
local universeId = tonumber(game.GameId) -- GameId corresponde ao UniverseId.

-- Primeiro o UniverseId, que permanece igual quando um jogo teleporta para outro PlaceId.
local selected = nil
for _, route in ipairs(Routes) do
    if route.UniverseId and universeId == route.UniverseId then
        selected = route
        break
    end
end

-- Fallback para os PlaceIds principais (inclusive Anime Piece).
if not selected then
    for _, route in ipairs(Routes) do
        if route.PlaceId and placeId == route.PlaceId then
            selected = route
            break
        end
    end
end

if not selected then
    warn(string.format("[Random Hub] Jogo nao suportado! PlaceId=%s / UniverseId=%s",
        tostring(placeId), tostring(universeId)))
    if KickUnsupported then
        local player = game:GetService("Players").LocalPlayer
        if player then pcall(function() player:Kick("Script Not Supported") end) end
    end
    return
end

local url = tostring(selected.Url or ""):match("^%s*(.-)%s*$")
if url == "" then
    warn("[Random Hub] Detectado: " .. selected.Name .. ". Falta adicionar a URL do script em Routes!")
    return
end
if not url:match("^https://") then
    warn("[Random Hub] URL invalida para " .. selected.Name .. ". Informe uma URL HTTPS com codigo Lua.")
    return
end
if type(loadstring) ~= "function" then
    warn("[Random Hub] loadstring nao esta disponivel neste ambiente.")
    return
end

-- Um unico download: somente o script do jogo em que o jogador esta.
print("[Random Hub] " .. selected.Name .. " detectado. Carregando loader externo...")
local okHttp, source = pcall(function()
    return game:HttpGet(url)
end)
if not okHttp or type(source) ~= "string" or source == "" then
    warn("[Random Hub] Falha ao baixar " .. selected.Name .. ": " .. tostring(source))
    return
end

local okCompile, chunk, compileError = pcall(loadstring, source, "RandomHub_" .. selected.Name)
if not okCompile or type(chunk) ~= "function" then
    warn("[Random Hub] Falha ao compilar o loader de " .. selected.Name .. ": " .. tostring(compileError or chunk))
    return
end

local okRun, runtimeError = pcall(chunk)
if not okRun then
    warn("[Random Hub] Erro ao executar " .. selected.Name .. ": " .. tostring(runtimeError))
end
