terms_seen = {}

function register_term(id, display_text)
  if not terms_seen[id] then
    terms_seen[id] = true
    tex.sprint(display_text .. [[\texttrademark{}\xspace]])
  else
    tex.sprint(display_text .. [[\xspace]])
  end
end
