# Agent Note: Model picker search

Status: implemented

English | [中文](2026-09-17-model-picker-search.zh.md)

## Problem

The model picker rendered every configured model in provider groups. A user with several providers or a large catalog had to scan the complete list, even when the model or provider identifier was already known.

## Decision

The model pane includes a localized search input above the provider groups. The Client normalizes the query by trimming surrounding whitespace and converting letters to lowercase, then matches it as a substring against each provider name, provider id, model name, and model id. Matching keeps the original provider grouping and order, while groups without a matching model disappear.

An empty normalized query displays the complete directory. A non-empty query with no match displays a distinct empty-search message without changing the directory's no-model state. Opening the picker clears the query, so a filter never carries into a later visit. Selecting a filtered result uses the existing session selection path and does not change catalog loading or provider discovery.

## Alternatives considered

**Search only model names.** Display names are useful for browsing but are not stable identifiers, and users commonly copy provider and model ids from configuration. Searching all four visible or configured identifiers makes the known-value path reliable without adding another search mode.

**Flatten matching models into one list.** A flat result list would reduce headings, but provider identity disambiguates models with repeated names and communicates which configured route the selection uses. Preserving groups also keeps filtered and unfiltered navigation consistent.

**Persist the last query.** Persistence saves retyping when reopening immediately, but it can make models appear missing on the next selection. Clearing on open gives each visit the complete catalog by default.

## Consequences

Filtering is entirely local to the loaded directory and does not issue provider requests. The picker retains provider context and selection behavior, while large catalogs require less scanning. The search input adds one localized control and one empty result state to the model pane.

## Testing

The ModelSelect component test covers case-insensitive model-id matching with surrounding whitespace, provider-name and provider-id matching, an empty query, no matches, selection from filtered results, and query reset after reopening.
