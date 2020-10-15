<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mcrmods="http://www.mycore.de/xslt/mods"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="mods fn xs mcrmods xlink">
  <xsl:output cdata-section-elements="description" method="xml" />
  <xsl:param name="WebApplicationBaseURL" required="yes" />
  <xsl:param name="MCR.ContentTransformer.mycoreobject-podcast.Owner.Name" required="yes" />
  <xsl:param name="MCR.ContentTransformer.mycoreobject-podcast.Owner.EMail" required="yes" />
  <xsl:variable name="marcrelator" select="document('classification:metadata:-1:children:marcrelator')" />
  <xsl:variable name="creatorRoles"
                select="$marcrelator/mycoreclass/categories/category[@ID='cre']/descendant-or-self::category"
                xmlns="" />
  <xsl:variable name="authorRoles"
                select="$marcrelator/mycoreclass/categories/category[@ID='aut']/descendant-or-self::category"
                xmlns="" />
  <xsl:include href="functions/mods.xsl" />

  <xsl:template match="/">
    <rss version="2.0">
      <xsl:apply-templates select="mycoreobject" mode="channel" />
    </rss>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="validateChannel">
    <xsl:variable name="mods" select="fn:exactly-one(metadata/def.modsContainer/modsContainer/mods:mods)" />
    <xsl:sequence select="if (count(structure/children/child) = 0)
      then fn:error((), concat('Podcast for document ', @ID, ' does not contain child documents!'))
      else ()" />
    <xsl:sequence select="if (count($mods/mods:language/mods:languageTerm[@authority='rfc5646']) != 1)
      then fn:error((), concat('Document ', @ID, ' does not define a language!'))
      else ()" />
    <xsl:sequence select="if (count($mods/mods:titleInfo[1]/mods:title) != 1)
      then fn:error((), concat('Document ', @ID, ' must have a single main title!'))
      else ()" />
    <xsl:sequence select="if (count($mods/mods:name[$creatorRoles/@ID=mods:role/mods:roleTerm/text()]) = 0)
      then fn:error((), concat('Document ', @ID, ' must have at least one author!'))
      else ()" />
    <xsl:sequence select="if (count(structure/derobjects/derobject[classification/@categid='thumbnail']) != 1)
      then fn:error((), concat('Document ', @ID, ' does not have a thumbnail!'))
      else ()" />
    <xsl:sequence select="if (count($mods/mods:abstract) != 1 and not(count($mods/mods:abstract) = 2 and $mods/mods:abstract[@altRepGroup]))
      then fn:error((), concat('Document ', @ID, ' does not have a description!'))
      else ()" />
    <xsl:sequence select="if (count($mods/mods:classification[@authorityURI='http://www.mycore.org/classifications/itunes-podcast']) != 1)
      then fn:error((), concat('Document ', @ID, ' must have an iTunes Podcast category!'))
      else ()" />
    <xsl:sequence select="if (/mycoreobject/service/servstates/servstate[@classid='state']/@categid != 'published')
      then fn:error((), concat('Podcast ', @ID, ' is not in state published: ',
            /mycoreobject/service/servstates/servstate[@classid='state']/@categid,'!'))
      else ()" />
  </xsl:template>

  <xsl:template match="mycoreobject" mode="channel">
    <xsl:apply-templates select="." mode="validateChannel" />
    <channel>
      <xsl:variable name="mods" select="fn:exactly-one(metadata/def.modsContainer/modsContainer/mods:mods)" />
      <xsl:variable name="language"
                    select="fn:exactly-one($mods/mods:language/mods:languageTerm[@authority='rfc5646'])" />
      <xsl:apply-templates select="$mods" mode="title" />
      <xsl:apply-templates select="." mode="link" />
      <language>
        <xsl:value-of select="$language" />
      </language>
      <itunes:explicit>false</itunes:explicit>
      <xsl:apply-templates select="$mods" mode="subtitle" />
      <xsl:apply-templates select="$mods" mode="author" />
      <xsl:apply-templates select="$mods" mode="description" />
      <itunes:owner>
        <itunes:name>
          <xsl:value-of select="$MCR.ContentTransformer.mycoreobject-podcast.Owner.Name" />
        </itunes:name>
        <itunes:email>
          <xsl:value-of select="$MCR.ContentTransformer.mycoreobject-podcast.Owner.EMail" />
        </itunes:email>
      </itunes:owner>
      <xsl:apply-templates select="." mode="thumbnail" />
      <xsl:apply-templates select="$mods" mode="category" />
      <xsl:variable name="items">
        <xsl:apply-templates select="fn:one-or-more(structure/children/child)" mode="item" />
      </xsl:variable>
      <xsl:perform-sort select="$items/node()">
        <xsl:sort select="if (pubDate) then (fn:parse-ietf-date(pubDate)) else (fn:current-dateTime())" />
        <xsl:sort select="fn:position()" />
      </xsl:perform-sort>
    </channel>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="thumbnail">
    <xsl:if test="fn:exactly-one(structure/derobjects/derobject[classification/@categid='thumbnail'])">
      <itunes:image
          href="{concat($WebApplicationBaseURL,'api/iiif/image/v2/thumbnail/',@ID,'/square/3000,/0/default.jpg')}" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:mods" mode="category">
    <xsl:variable name="itunes-category"
                  select="fn:exactly-one(mods:classification[@authorityURI='http://www.mycore.org/classifications/itunes-podcast'])" />
    <xsl:variable name="mycoreclass" select="mcrmods:to-mycoreclass($itunes-category, 'parent')" />
    <xsl:apply-templates select="$mycoreclass/categories/category" mode="category" />
  </xsl:template>

  <xsl:template match="category" mode="category">
    <itunes:category text="{label[lang('en')]/@text}">
      <xsl:apply-templates select="category" mode="category" />
    </itunes:category>
  </xsl:template>

  <xsl:template match="mods:mods" mode="title">
    <title>
      <xsl:value-of select="fn:exactly-one(mods:titleInfo[1]/mods:title)" />
    </title>
  </xsl:template>

  <xsl:template match="mods:mods" mode="subtitle">
    <xsl:if test="mods:titleInfo[1]/mods:subTitle">
      <itunes:subtitle>
        <xsl:value-of select="fn:exactly-one(mods:titleInfo[1]/mods:subTitle)" />
      </itunes:subtitle>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:mods" mode="author">
    <xsl:if test="mods:name[$creatorRoles/@ID=mods:role/mods:roleTerm/text()]">
      <itunes:author>
        <xsl:variable name="authors" select="mods:name[$authorRoles/@ID=mods:role/mods:roleTerm/text()]" />
        <xsl:choose>
          <xsl:when test="count($authors) &gt; 0">
            <xsl:for-each select="$authors">
              <xsl:apply-templates select="." mode="creator" />
              <xsl:if test="position() != last()">
                <xsl:value-of select="'; '" />
              </xsl:if>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="fn:one-or-more(mods:name[$creatorRoles/@ID=mods:role/mods:roleTerm/text()])">
              <xsl:apply-templates select="." mode="creator" />
              <xsl:if test="position() != last()">
                <xsl:value-of select="'; '" />
              </xsl:if>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </itunes:author>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:name" mode="creator">
    <xsl:choose>
      <xsl:when test="mods:displayForm">
        <xsl:value-of select="mods:displayForm" />
      </xsl:when>
      <xsl:when test="mods:etal/text()">
        <xsl:value-of select="mods:etal" />
      </xsl:when>
      <xsl:when test="mods:etal">
        <xsl:value-of select="'et. al.'" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="link">
    <link>
      <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',@ID)" />
    </link>
  </xsl:template>

  <xsl:template match="mods:mods" mode="description">
    <xsl:if test="mods:abstract">
      <description>
        <xsl:attribute name="xml:space">preserve</xsl:attribute>
        <xsl:choose>
          <xsl:when test="mods:abstract[@altRepGroup and @contentType='text/xml']">
              <xsl:copy-of
                  select="document(fn:exactly-one(mods:abstract[@altRepGroup and @contentType='text/xml'])/@altFormat)/*/node()" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="fn:exactly-one(mods:abstract)" />
          </xsl:otherwise>
        </xsl:choose>
      </description>
    </xsl:if>
  </xsl:template>

  <!-- RSS-Items -->

  <xsl:template match="child" mode="item">
    <xsl:apply-templates select="document(concat('mcrobject:',@xlink:href))/mycoreobject" mode="item" />
  </xsl:template>

  <xsl:template match="mycoreobject" mode="validateItem">
    <xsl:variable name="mods" select="fn:exactly-one(metadata/def.modsContainer/modsContainer/mods:mods)" />
    <xsl:if test="count(structure/children/child) != 0">
      <xsl:comment>
        <xsl:value-of select="concat('Podcast episode for document ', @ID, ' may not contain child documents!')" />
      </xsl:comment>
    </xsl:if>
    <xsl:if test="count($mods/mods:titleInfo[1]/mods:title) != 1">
      <xsl:comment>
        <xsl:value-of select="concat('Document ', @ID, ' must have a single main title!')" />
      </xsl:comment>
    </xsl:if>
    <xsl:if test="count(structure/derobjects/derobject[classification/@categid='content']) != 1">
      <xsl:comment>
        <xsl:value-of select="concat('Document ', @ID, ' does not have a derivate of type content!')" />
      </xsl:comment>
    </xsl:if>
    <xsl:if test="count($mods/mods:abstract) != 1 and
      not(count($mods/mods:abstract) = 2 and $mods/mods:abstract[@altRepGroup]) and
      not($mods/mods:relatedItem[@type='host']/mods:part/@order = 0)">
      <xsl:comment>
        <xsl:value-of select="concat('Document ', @ID, ' does not have a description!')" />
      </xsl:comment>
    </xsl:if>
    <xsl:variable name="pubDate"
                  select="$mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf']" />
    <xsl:choose>
      <xsl:when test="count($pubDate) != 1">
        <xsl:comment>
          <xsl:value-of select="concat('Document ', @ID, ' does not have a publication date!')" />
        </xsl:comment>
      </xsl:when>
      <xsl:when test="not($pubDate castable as xs:date)">
        <xsl:comment>
          <xsl:value-of select="concat('Document ', @ID, ' publication date is not valid: ',$pubDate,'!')" />
        </xsl:comment>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="pubDateTime"
                      select="fn:dateTime($pubDate, xs:time(fn:format-time(fn:current-time(),'00:00:00[Z]')))" />
        <xsl:if test="fn:current-dateTime() &lt; $pubDateTime">
          <xsl:comment>
            <xsl:value-of select="concat('Podcast episode ', @ID, ' will be published on ',$pubDateTime,'.')" />
          </xsl:comment>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:variable name="extent" select="$mods/mods:physicalDescription/mods:extent" />
    <xsl:choose>
      <xsl:when test="count($extent) != 1">
        <xsl:comment>
          <xsl:value-of select="concat('Podcast episode ', @ID, ' does not have an extent defined!')" />
        </xsl:comment>
      </xsl:when>
      <xsl:when test="not(fn:matches($extent/text(), '^(\d+:\d{2})|(\d{1,2}):\d{2}$'))">
        <xsl:value-of select="concat('Podcast episode ', @ID, ' extent is not in [HH:]MM:SS format: ',$extent,'!')" />
      </xsl:when>
    </xsl:choose>
    <xsl:if test="/mycoreobject/service/servstates/servstate[@classid='state']/@categid != 'published'">
      <xsl:comment>
        <xsl:value-of
            select="concat('Podcast episode ', @ID, ' is not in state published: ',
            /mycoreobject/service/servstates/servstate[@classid='state']/@categid,'!')" />
      </xsl:comment>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="item">
    <xsl:variable name="itemValidation">
      <xsl:apply-templates select="." mode="validateItem" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="count($itemValidation/node()) &gt; 0">
        <xsl:for-each select="$itemValidation/node()">
          <xsl:sequence select="." />
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <item>
          <xsl:variable name="mods" select="fn:exactly-one(metadata/def.modsContainer/modsContainer/mods:mods)" />
          <xsl:apply-templates select="$mods" mode="title" />
          <xsl:apply-templates select="." mode="link" />
          <xsl:apply-templates select="$mods" mode="author" />
          <xsl:apply-templates select="$mods" mode="subtitle" />
          <xsl:apply-templates select="$mods" mode="description" />
          <xsl:apply-templates select="." mode="enclosure" />
          <xsl:if test="$mods/mods:relatedItem[@type='host']/mods:part/@order = 0">
            <itunes:episodeType>trailer</itunes:episodeType>
          </xsl:if>
          <guid>
            <xsl:value-of select="fn:exactly-one(@ID)" />
          </guid>
          <pubDate>
            <xsl:variable name="pubDate"
                          select="fn:exactly-one($mods/mods:originInfo[@eventType='publication']/mods:dateIssued[@encoding='w3cdtf'])" />
            <xsl:variable name="pubDateTime"
                          select="fn:dateTime($pubDate, xs:time(fn:format-time(fn:current-time(),'00:00:00[Z]')))" />
            <xsl:value-of
                select="fn:format-dateTime($pubDateTime,'[FNn,3-3], [D,2] [MNn,3-3] [Y] [H01]:[m01]:[s01] [Z0000]')" />
          </pubDate>
          <itunes:duration>
            <xsl:value-of select="$mods/mods:physicalDescription/mods:extent" />
          </itunes:duration>
        </item>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="enclosure">
    <xsl:variable name="contentDerivate"
                  select="fn:exactly-one(structure/derobjects/derobject[classification/@categid='content'])" />
    <xsl:variable name="mainDocPath"
                  select="concat('ifs:/',$contentDerivate/@xlink:href,'/',fn:iri-to-uri($contentDerivate/maindoc))" />
    <xsl:variable name="maindocDir" select="fn:resolve-uri('.',$mainDocPath)" />
    <xsl:variable name="directory" select="document($maindocDir)/mcr_directory" />
    <xsl:variable name="file" select="$directory/children/child[name=$contentDerivate/maindoc]" />
    <enclosure>
      <xsl:attribute name="url">
        <xsl:value-of select="concat($WebApplicationBaseURL,
        'api/v2/objects/',
        @ID,
        '/derivates/',
        $contentDerivate/@xlink:href,
        '/contents',
        fn:iri-to-uri($directory/path),
        fn:iri-to-uri($file/name))" />
      </xsl:attribute>
      <xsl:attribute name="length">
        <xsl:value-of select="$file/size" />
      </xsl:attribute>
      <xsl:attribute name="type">
        <xsl:value-of select="$file/contentType" />
      </xsl:attribute>
    </enclosure>
  </xsl:template>

</xsl:stylesheet>
