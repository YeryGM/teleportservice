local SubtitlesSelectors = require(script.Parent.Parent.store.subtitles.SubtitlesSelectors)
local useStoreSelector = require(script.Parent.useStoreSelector)

local useSubtitles = {}

function useSubtitles.useVisible()
    return useStoreSelector(SubtitlesSelectors.selectVisible)
end

function useSubtitles.useLoading()
    return useStoreSelector(SubtitlesSelectors.selectLoading)
end

function useSubtitles.useError()
    return useStoreSelector(SubtitlesSelectors.selectError)
end

function useSubtitles.useSubtitle(sectionId: number)
    return useStoreSelector(function(state)
        local sections = SubtitlesSelectors.selectSubtitles(state)
        return SubtitlesSelectors.selectSectionSubtitle(sections, sectionId)
    end)
end

function useSubtitles.useSectionVisible(sectionId: number)
    return useStoreSelector(function(state)
        local sectionsVisible = SubtitlesSelectors.selectSectionsVisible(state)
        return SubtitlesSelectors.selectSectionVisible(sectionsVisible, sectionId)
    end)
end

function useSubtitles.useSubtitles()
    return useStoreSelector(SubtitlesSelectors.selectSubtitles)
end

return useSubtitles
