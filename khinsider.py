from __future__ import unicode_literals

from .common import InfoExtractor

import re


class KHInsiderAlbumIE(InfoExtractor):
    _VALID_URL = r'https?://downloads\.khinsider\.com/game-soundtracks/album/(?P<id>[A-Za-z0-9-]+)$'
    _TEST = {
        'url': 'https://downloads.khinsider.com/game-soundtracks/album/super-mario-bros',
        'info_dict': {
            'id': 'super-mario-bros',
            'title': 'Super Mario Bros'
        },
        'playlist_count': 18
    }

    def _real_extract(self, url):
        playlist_id = self._match_id(url)
        webpage = self._download_webpage(url, playlist_id)
        title = self._html_search_regex(r'<h2>(.*)</h2>', webpage, 'title')
        entries = []
        for a, b in re.findall(r'<td class="clickable-row"><a[^>]*href="(.+)"[^>]*>(.+)</a></td>', webpage):
            entries.append({
                '_type': 'url',
                'id': a[25 + len(playlist_id):],
                'title': b,
                'url': 'https://downloads.khinsider.com' + a,
                'ie_key': 'KHInsiderTrack'
            })

        return {
            '_type': 'playlist',
            'id': playlist_id,
            'title': title,
            'entries': entries
        }


class KHInsiderTrackIE(InfoExtractor):
    _VALID_URL = r'https?://downloads\.khinsider\.com/game-soundtracks/album/[A-Za-z0-9-]+\/(?P<id>.+)'
    _TEST = {
        'url': 'https://downloads.khinsider.com/game-soundtracks/album/super-mario-bros/01%2520-%2520Super%2520Mario%2520Bros.mp3',
        'info_dict': {
            'id': '01%2520-%2520Super%2520Mario%2520Bros.mp3',
            'ext': 'mp3',
            'title': 'Super Mario Bros'
        }
    }

    def _real_extract(self, url):
        video_id = self._match_id(url)
        webpage = self._download_webpage(url, video_id)
        title = self._html_search_regex(r'Song name: <b>(.*)</b>', webpage, 'title')
        formats = []
        for a in re.findall(r'<a[^>]*href="(.+)"[^>]*><span[^>]*class="songDownloadLink"[^>]*>', webpage):
            formats.append({
                'url': a
            })

        return {
            'id': video_id,
            'title': title,
            'formats': formats
        }
