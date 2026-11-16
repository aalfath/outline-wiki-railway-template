# Outline, the open-source team wiki, packaged for Railway.
# Upstream image pinned by version and digest. To update, bump both on a branch,
# add a CHANGELOG.md entry and merge to main: Railway then offers the update
# to everyone who deployed the template.
FROM outlinewiki/outline:1.13.0@sha256:4583bb244dbb4464d8a632c75044d3b2f9fe44382b6a4b84d97995f473b823e4

# Start as root only to fix the ownership of the Railway volume (mounted as
# root), then drop to the image's own nodejs user (uid 1001) in start.sh.
USER root
COPY --chmod=0755 start.sh /usr/local/bin/outline-railway-start

EXPOSE 3000
ENTRYPOINT ["/usr/local/bin/outline-railway-start"]
