# SPDX-FileCopyrightText: 2021 Carl Schwan <carlschwan@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

add_definitions(-DDATA_DIR="${CMAKE_CURRENT_SOURCE_DIR}" )

ecm_add_test(hashhelpertest.cpp
    TEST_NAME hashhelpertest
    LINK_LIBRARIES hashomatic_static Qt::Test
    NAME_PREFIX "app-"
)

ecm_add_test(controllertest.cpp
    TEST_NAME controllertest
    LINK_LIBRARIES hashomatic_static Qt::Test
    NAME_PREFIX "app-"
)
