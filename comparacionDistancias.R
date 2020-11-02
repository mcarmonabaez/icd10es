library(tidyverse)
library(stringdist)

pruebas1 <- subcategories %>%
  mutate(qgram =   stringsim('insuficiencia respiratoria grave', disease, method = 'qgram', q = 3),
         cosine =  stringsim('insuficiencia respiratoria grave', disease, method = 'cosine'),
         # jaccard = stringsim('insuficiencia respiratoria grave', disease, method = 'jaccard'),
         jw =      stringsim('insuficiencia respiratoria grave', disease, method = 'jw'),
         lv =      stringsim('insuficiencia respiratoria grave', disease, method = 'lv'))

pruebas2 <- subcategories %>%
  mutate(qgram =   stringsim('neumonia', disease, method = 'qgram', q = 3),
         cosine =  stringsim('neumonia', disease, method = 'cosine'),
         jw =      stringsim('neumonia', disease, method = 'jw'),
         lv =      stringsim('neumonia', disease, method = 'lv'))

pruebas3 <- subcategories %>%
  mutate(qgram =   stringsim('bronconeumonia', disease, method = 'qgram', q = 3),
         cosine =  stringsim('bronconeumonia', disease, method = 'cosine'),
         jw =      stringsim('bronconeumonia', disease, method = 'jw'),
         lv =      stringsim('bronconeumonia', disease, method = 'lv'))

pruebas4 <- subcategories %>%
  mutate(qgram =   stringsim('bronquitis', disease, method = 'qgram', q = 3),
         cosine =  stringsim('bronquitis', disease, method = 'cosine'),
         jw =      stringsim('bronquitis', disease, method = 'jw'),
         lv =      stringsim('bronquitis', disease, method = 'lv'))

pruebas5 <- subcategories %>%
  filter(term == 'Canonical') %>%
  mutate(qgram =   stringsim('bronquitis', disease, method = 'qgram', q = 3),
         cosine =  stringsim('bronquitis', disease, method = 'cosine'),
         jw =      stringsim('bronquitis', disease, method = 'jw'),
         lv =      stringsim('bronquitis', disease, method = 'lv'))

pruebas4 %>%
  gather(metrica, valor, qgram:lv) %>%
  group_by(metrica) %>%
  top_n(6, valor) %>%
  arrange(-valor) %>%
  mutate(id = rank(valor, ties.method = 'first'))  %>%
  ungroup() %>%
  select(-c(category, subcategory, term, valor)) %>%
  spread(metrica, disease) %>%
  arrange(-id) %>%
  clipr::write_clip()

pruebas4 %>%
  gather(metrica, valor, qgram:lv) %>%
  group_by(metrica) %>%
  top_n(6, valor) %>%
  arrange(-valor) %>%
  mutate(id = rank(valor, ties.method = 'first'))  %>%
  ungroup() %>%
  select(-c(category, subcategory, term, disease)) %>%
  spread(metrica, valor) %>%
  arrange(-id) %>%
clipr::write_clip()


