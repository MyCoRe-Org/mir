<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrurl="http://www.mycore.de/xslt/url"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:mode on-no-match="shallow-copy" />

  <xsl:variable name="headerCols">
    <xsl:apply-templates mode="dataTableHeader" select="." />
  </xsl:variable>

  <xsl:variable name="defaultPage" select="1" />
  <xsl:variable name="defaultNumPerPage" select="10" />
  <xsl:variable name="defaultSortBy">
    <xsl:value-of select="($headerCols/(col|th))[1][@sortOrder != '']/@sortBy" />
  </xsl:variable>
  <xsl:variable name="defaultSortOrder">
    <xsl:value-of select="($headerCols/(col|th))[1]/@sortOrder" />
  </xsl:variable>

  <xsl:variable name="SortBy" select="(mcrurl:get-param($RequestURL, 'SortBy')[. != ''], $defaultSortBy)[1]" />
  <xsl:variable name="SortOrder" select="(mcrurl:get-param($RequestURL, 'SortOrder')[. != ''], $defaultSortOrder)[1]" />
  <xsl:variable name="SortType" select="
    let $sortType := mcrurl:get-param($RequestURL, 'SortType'),
        $type := string(($headerCols/(col|th))[1]/@sortType)
    return if ($sortType != '') then $sortType
           else if ($type != '') then $type
           else 'text'
  " />

  <xsl:variable name="numPerPage" select="
    xs:integer((mcrurl:get-param($RequestURL, 'numPerPage')[. != ''], $defaultNumPerPage)[1])
  " />
  <xsl:variable name="Filter" select="mcrurl:get-param($RequestURL, 'Filter')" />
  <xsl:variable name="Page" select="xs:integer((mcrurl:get-param($RequestURL, 'Page')[. != ''], $defaultPage)[1])" />

  <xsl:variable name="dataTableNumPerPageList" select="(10, 25, 50, 100)" />

  <xsl:template mode="dataTable" match="*">
    <xsl:param name="id" select="'dataTable'" />
    <xsl:param name="i18nprefix" select="'dataTable'" />
    <xsl:param name="disableFilter" select="false()" />

    <!-- get total records from root element or count -->
    <xsl:variable name="nativeLimit" select="string-length(@total) &gt; 0" />
    <xsl:variable name="total" select="if (@total != '') then xs:integer(@total) else count(./*)" />
    <xsl:variable name="pages" select="xs:integer(ceiling($total div $numPerPage))" />
    <xsl:variable name="end" select="
      xs:integer(if (($Page * $numPerPage) gt $total) then $total else ($Page * $numPerPage))
    " />
    <xsl:variable name="start" select="
      xs:integer(
        if ($total = 0) then 0
        else if ($Page gt $pages) then 1
        else if ($end = 0) then $end
        else (($Page - 1) * $numPerPage) + 1
      )
    " />

    <div id="{$id}_wrapper" class="datatable card">
      <div class="card-head clearfix">
        <form id="{$id}_form" class="row form-inline">
          <!-- build hidden values -->
          <xsl:call-template name="dataTableFormValues" />

          <xsl:variable name="colWidth" select="if (not($disableFilter)) then 6 else 12" />

          <xsl:if test="$disableFilter = false()">
            <!-- entries filter -->
            <div class="col-{$colWidth}">
              <div class="mir-form-group no-margin" id="{$id}_filter">
                <label>
                  <span class="fas fa-filter" aria-hidden="true" />
                  <xsl:value-of select="mcri18n:translate($i18nprefix || '.filter')" />
                  <xsl:text>&#160;</xsl:text>
                  <input class="form-control input-sm" type="search" name="Filter">
                    <xsl:attribute name="value">
                      <xsl:if test="string-length($Filter) &gt; 0">
                        <xsl:value-of select="$Filter" />
                      </xsl:if>
                    </xsl:attribute>
                  </input>
                </label>
              </div>
            </div>
          </xsl:if>

          <!-- numPerPage selector -->
          <div>
            <xsl:attribute name="class">
              <xsl:choose>
                <xsl:when test="$disableFilter = true()">
                  <xsl:value-of select="concat('offset-', $colWidth div 2, ' col-', $colWidth div 2)" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat(' col-', $colWidth)" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <div id="{$id}_length" class="mir-form-group float-end no-margin form-select">
              <label>
                <select class="form-control form-select input-sm" name="numPerPage" size="1" onchange="this.form.submit()">
                  <xsl:for-each select="$dataTableNumPerPageList">
                    <option value="{.}" selected="{if (. = $numPerPage) then 'selected' else ''}">
                      <xsl:value-of select="." />
                    </option>
                  </xsl:for-each>
                </select>
                <xsl:text>&#160;</xsl:text>
                <xsl:value-of select="mcri18n:translate($i18nprefix || '.lengthMenu')" />
                <noscript>
                  <input class="btn" type="submit" name="Ok" value="Ok" />
                </noscript>
              </label>
            </div>
          </div>
        </form>
      </div>
      <!-- build DataTable -->
      <div class="table-responsive">
        <table class="table table-striped" id="{$id}">
          <xsl:call-template name="dataTableHeader" />
          <xsl:choose>
            <xsl:when test="$end = 0">
              <tr class="odd" align="center">
                <td colspan="{$dataTableHeaderColCount}">
                  <xsl:value-of select="mcri18n:translate($i18nprefix || '.noItemFound')" />
                </td>
              </tr>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="dataTableBody">
                <xsl:with-param name="nativeLimit" select="$nativeLimit" />
                <xsl:with-param name="start" select="$start" />
                <xsl:with-param name="end" select="$end" />
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </table>
      </div>
      <div class="card-footer clearfix">
        <span id="{$id}_info">
          <xsl:if test="$pages &gt; 1">
            <xsl:attribute name="class">d-none d-sm-block</xsl:attribute>
          </xsl:if>
          <xsl:variable name="i18n-params" select="(string($start), string($end), string($total))" />
          <xsl:value-of select="mcri18n:translate-with-params($i18nprefix || '.filterInfo', $i18n-params)" />
        </span>
        <xsl:if test="$pages &gt; 1">
          <xsl:call-template name="dataTablePaginate">
            <xsl:with-param name="id" select="$id" />
            <xsl:with-param name="i18nprefix" select="$i18nprefix" />
            <xsl:with-param name="pages" select="$pages" />
          </xsl:call-template>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="dataTableHeader">
    <thead>
      <tr>
        <xsl:for-each select="$headerCols/(col|th)">
          <xsl:variable name="sortOrderAfter">
            <xsl:choose>
              <xsl:when test="($SortBy = @sortBy) and ($SortOrder = 'asc')">
                <xsl:text>desc</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>asc</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="iconClass">
            <xsl:choose>
              <xsl:when test="($SortBy = @sortBy) and ($SortOrder = 'asc')">
                <xsl:text>fas fa-sort-amount-up-alt</xsl:text>
              </xsl:when>
              <xsl:when test="($SortBy = @sortBy) and ($SortOrder = 'desc')">
                <xsl:text>fas fa-sort-amount-down-alt</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>fas fa-sort</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <th>
            <xsl:copy-of select="@*[not(contains('sortBy|sortOrder|sortType', name()))]" />
            <xsl:choose>
              <xsl:when test="string-length(@sortBy) &gt; 0">
                <a>
                  <xsl:attribute name="href">
                    <xsl:call-template name="dataTableQuerystring">
                      <xsl:with-param name="sortBy" select="@sortBy" />
                      <xsl:with-param name="sortOrder" select="$sortOrderAfter" />
                      <xsl:with-param name="sortType">
                        <xsl:choose>
                          <xsl:when test="@sortType">
                            <xsl:value-of select="@sortType" />
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>text</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:attribute>
                  <xsl:value-of select="text()" />
                  <span class="float-start {$iconClass} sort-icon" />
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="text()" />
              </xsl:otherwise>
            </xsl:choose>
          </th>
        </xsl:for-each>
      </tr>
    </thead>
  </xsl:template>

  <xsl:template name="dataTableBody">
    <xsl:param name="nativeLimit" select="false" />
    <xsl:param name="start" as="xs:integer" />
    <xsl:param name="end" as="xs:integer" />

    <xsl:variable name="sortedCol" select="$dataTableSortedCol" />

    <tbody>
      <xsl:for-each select="./*">
        <xsl:sort
          select="*[name() = $SortBy]|@*[name() = $SortBy]|text()[$SortBy = 'text()']|descendant-or-self::*[name() = $SortBy]|descendant-or-self::*//@*[name() = $SortBy]"
          order="{if ($SortOrder = 'desc') then 'descending' else 'ascending'}"
          data-type="{$SortType}" />

        <xsl:if test="((position() &gt;= $start) and (position() &lt;= $end)) or ($nativeLimit)">
          <xsl:variable name="trClass">
            <xsl:choose>
              <xsl:when test="position() mod 2 = 0">
                <xsl:text>even</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>odd</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="drow">
            <xsl:apply-templates mode="dataTableRow" select="." />
          </xsl:variable>

          <xsl:variable name="row">
            <xsl:choose>
              <xsl:when test="$drow/(row|tr)">
                <xsl:copy-of select="$drow" />
              </xsl:when>
              <xsl:otherwise>
                <row>
                  <xsl:copy-of select="$drow" />
                </row>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:for-each select="$row/(row|tr)">
            <tr class="{$trClass}">
              <!-- extra css class for row -->
              <xsl:if test="./class">
                <xsl:attribute name="class" select="$trClass || ' ' || ./class" />
              </xsl:if>
              <xsl:apply-templates select="@*" />
              <xsl:for-each select="./col|./td">
                <xsl:variable name="tdClass">
                  <xsl:if test="$sortedCol = position()">
                    <xsl:text>sorting_1</xsl:text>
                  </xsl:if>
                </xsl:variable>
                <td>
                  <xsl:if test="string-length($tdClass) &gt; 0">
                    <xsl:attribute name="class">
                      <xsl:value-of select="$tdClass" />
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:apply-templates select="@*|node()" />
                </td>
              </xsl:for-each>
            </tr>
          </xsl:for-each>
        </xsl:if>
      </xsl:for-each>
    </tbody>
  </xsl:template>

  <xsl:template name="dataTablePaginate">
    <xsl:param name="id" as="xs:string" select="'dataTable'" />
    <xsl:param name="i18nprefix" as="xs:string" select="'dataTable'" />
    <xsl:param name="pages" as="xs:integer" />

    <ul id="{$id}_paginate" class="pagination pagination-sm float-end no-margin">
      <li>
        <xsl:choose>
          <xsl:when test="$Page &gt; 1">
            <a tabindex="0" id="{$id}_first">
              <xsl:attribute name="href">
                  <xsl:call-template name="dataTableQuerystring">
                    <xsl:with-param name="page" select="1" />
                  </xsl:call-template>
                </xsl:attribute>
              <xsl:text>«</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="mcri18n:translate($i18nprefix || '.first')" />
              </span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">disabled</xsl:attribute>
            <span>
              <xsl:text>«</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="mcri18n:translate($i18nprefix || '.first')" />
              </span>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </li>
      <li>
        <xsl:choose>
          <xsl:when test="$Page &gt; 1">
            <a tabindex="0" id="{$id}_previous">
              <xsl:attribute name="href">
                  <xsl:call-template name="dataTableQuerystring">
                    <xsl:with-param name="page" select="$Page - 1" />
                  </xsl:call-template>
                </xsl:attribute>
              <xsl:text>‹</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="mcri18n:translate($i18nprefix || '.previous')" />
              </span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">disabled</xsl:attribute>
            <span>
              <xsl:text>‹</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="mcri18n:translate($i18nprefix || '.previous')" />
              </span>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </li>

      <!-- variable can be used to change numbers of Page entries to display -->
      <xsl:variable name="paginateMaxEntries" as="xs:integer" select="5" />
      <xsl:variable name="paginateBackCount" select="xs:integer(ceiling(($paginateMaxEntries - 1) div 2))" />
      <xsl:variable name="paginatePrevCount" select="xs:integer($paginateMaxEntries - ceiling($paginateMaxEntries div 2))" />
      <xsl:variable name="paginateStart" select="
        if (($Page - $paginateBackCount) le 1 or $pages lt $paginateMaxEntries) then 1
        else if (($Page + $paginatePrevCount) gt $pages) then $Page - $paginateBackCount - (($Page + $paginatePrevCount) - $pages)
        else $Page - $paginateBackCount
      " />
      <xsl:variable name="paginateEnd" select="
        if (($Page + $paginatePrevCount) ge $pages or $pages lt $paginateMaxEntries) then $pages
        else if (($Page + $paginatePrevCount) lt $paginateMaxEntries) then $paginateMaxEntries
        else $Page + $paginatePrevCount
      " />

      <xsl:call-template name="dataTablePaginateEntries">
        <xsl:with-param name="pages" select="$pages" />
        <xsl:with-param name="paginateStart" select="$paginateStart" />
        <xsl:with-param name="paginateEnd" select="$paginateEnd" />
      </xsl:call-template>

      <li>
        <xsl:choose>
          <xsl:when test="$Page &lt; $pages">
            <a tabindex="0" id="{$id}_next">
              <xsl:attribute name="href">
                  <xsl:call-template name="dataTableQuerystring">
                    <xsl:with-param name="page" select="$Page + 1" />
                  </xsl:call-template>
                </xsl:attribute>
              <xsl:text>›</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="mcri18n:translate($i18nprefix || '.next')" />
              </span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">disabled</xsl:attribute>
            <span>
              <xsl:text>›</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="mcri18n:translate($i18nprefix || '.next')" />
              </span>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </li>
      <li>
        <xsl:choose>
          <xsl:when test="$Page &lt; $pages">
            <a tabindex="0" id="{$id}_last">
              <xsl:attribute name="href">
                <xsl:call-template name="dataTableQuerystring">
                  <xsl:with-param name="page" select="$pages" />
                </xsl:call-template>
              </xsl:attribute>
              <xsl:text>»</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="mcri18n:translate($i18nprefix || '.last')" />
              </span>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">disabled</xsl:attribute>
            <span>
              <xsl:text>»</xsl:text>
              <span class="sr-only">
                <xsl:value-of select="mcri18n:translate($i18nprefix || '.last')" />
              </span>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </li>
    </ul>
  </xsl:template>

  <xsl:template name="dataTablePaginateEntries">
    <xsl:param name="pages" as="xs:integer" />
    <xsl:param name="paginateStart" as="xs:integer" />
    <xsl:param name="paginateEnd" as="xs:integer" />

    <xsl:if test="$paginateStart = $Page">
      <li class="active">
        <span>
          <xsl:value-of select="$paginateStart" />
        </span>
      </li>
    </xsl:if>
    <xsl:if test="$paginateStart != $Page">
      <li>
        <a tabindex="0">
          <xsl:attribute name="href">
            <xsl:call-template name="dataTableQuerystring">
              <xsl:with-param name="page" select="$paginateStart" />
            </xsl:call-template>
          </xsl:attribute>
          <xsl:value-of select="$paginateStart" />
        </a>
      </li>
    </xsl:if>

    <xsl:if test="$paginateStart &lt; $paginateEnd">
      <xsl:call-template name="dataTablePaginateEntries">
        <xsl:with-param name="pages" select="$pages" />
        <xsl:with-param name="paginateStart" select="$paginateStart + 1" />
        <xsl:with-param name="paginateEnd" select="$paginateEnd" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Helper Variables/Functions -->

  <xsl:variable name="dataTableHeaderColCount" select="count($headerCols/(col|th))" />

  <xsl:variable name="dataTableSortedCol" select="(index-of($headerCols/(col|th)/@sortBy, $SortBy), 0)[1]" />

  <xsl:template name="dataTableQuerystring">
    <xsl:param name="sortBy" select="$SortBy" />
    <xsl:param name="sortOrder" select="$SortOrder" />
    <xsl:param name="sortType" select="$SortType" />
    <xsl:param name="perPage" select="$numPerPage" />
    <xsl:param name="page" select="$Page" />
    <xsl:param name="filter" select="$Filter" />

    <xsl:variable name="url1" select="mcrurl:set-param($RequestURL, 'SortBy', $sortBy)" />
    <xsl:variable name="url2" select="mcrurl:set-param($url1, 'SortOrder', $sortOrder)" />
    <xsl:variable name="url3" select="mcrurl:set-param($url2, 'SortType', $sortType)" />
    <xsl:variable name="url4" select="mcrurl:set-param($url3, 'numPerPage', $perPage)" />
    <xsl:variable name="url5" select="mcrurl:set-param($url4, 'Page', $page)" />
    <xsl:variable name="url6" select="mcrurl:set-param($url5, 'Filter', $filter)" />
    <xsl:value-of select="$url6" />
  </xsl:template>

  <xsl:template name="dataTableFormValues">
    <xsl:param name="sortBy" select="$SortBy" />
    <xsl:param name="sortOrder" select="$SortOrder" />
    <xsl:param name="sortType" select="$SortType" />
    <xsl:param name="page" select="1" as="xs:integer" />

    <xsl:variable name="queryString" select="
      if (contains($RequestURL, '?')) then substring-after($RequestURL, '?') else $RequestURL
    " />

    <xsl:for-each select="tokenize($queryString, '&amp;')">
      <xsl:variable name="name" select="substring-before(., '=')" />
      <xsl:variable name="value" select="substring-after(., '=')" />

      <xsl:if test="not(contains('SortBy|SortOrder|SortType|Page|Filter|numPerPage', $name))">
        <input type="hidden" name="{$name}" value="{$value}" />
      </xsl:if>
    </xsl:for-each>

    <input type="hidden" name="SortBy" value="{$sortBy}" />
    <input type="hidden" name="SortOrder" value="{$sortOrder}" />
    <input type="hidden" name="SortType" value="{$sortType}" />
    <input type="hidden" name="Page" value="{$page}" />
  </xsl:template>

</xsl:stylesheet>
